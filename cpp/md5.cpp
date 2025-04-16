#include "md5.h"

#include <windows.h>
#include <wincrypt.h>
#include <iostream>
#include <fstream>
#include <string>

#pragma comment(lib, "crypt32.lib")

#ifdef NEVER
std::string md5(const std::string& filename) {
    std::ifstream file(filename.c_str(), std::ios::binary);
    if (!file) return "";

    HCRYPTPROV hProv = 0;
    if (!CryptAcquireContext(&hProv, NULL, NULL, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT))
        return "";

    HCRYPTHASH hHash = 0;
    if (!CryptCreateHash(hProv, CALG_MD5, 0, 0, &hHash)) {
        CryptReleaseContext(hProv, 0);
        return "";
    }

    const int bufSize = 4096;
    char buffer[bufSize];
    while (file.good()) {
        file.read(buffer, bufSize);
        DWORD bytesReaded = static_cast<DWORD>(file.gcount());
        if (!CryptHashData(hHash, reinterpret_cast<BYTE*>(buffer), bytesReaded, 0)) {
            CryptDestroyHash(hHash);
            CryptReleaseContext(hProv, 0);
            return "";
        }
    }

    DWORD hashLen = 16;
    BYTE hash[16];
    if (CryptGetHashParam(hHash, HP_HASHVAL, hash, &hashLen, 0)) {
        std::string result;
        char hex[3];
        for (int i = 0; i < hashLen; ++i) {
            sprintf_s(hex, "%02x", hash[i]);
            result += hex;
        }
        CryptDestroyHash(hHash);
        CryptReleaseContext(hProv, 0);
        return result;
    }
    CryptDestroyHash(hHash);
    CryptReleaseContext(hProv, 0);
    return "";
}
#endif

extern bool md5(const uint8* content, uint32 size, uint64 &hi, uint64 &lo)
{
    hi = 0;
    lo = 0;

    HCRYPTPROV hProv = 0;
    if (!CryptAcquireContext(&hProv, NULL, NULL, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT))
        return false;

    HCRYPTHASH hHash = 0;
    if (!CryptCreateHash(hProv, CALG_MD5, 0, 0, &hHash)) {
        CryptReleaseContext(hProv, 0);
        return false;
    }

    if (!CryptHashData(hHash, reinterpret_cast<BYTE*>(const_cast<uint8*>(content)), size, 0)) {
        CryptDestroyHash(hHash);
        CryptReleaseContext(hProv, 0);
        return false;
    }

    DWORD hashLen = 16;
    BYTE hash[16];
    if (CryptGetHashParam(hHash, HP_HASHVAL, hash, &hashLen, 0)) {
        std::string result;
        char hex[3];
        for (int i = 0; i < int(hashLen); ++i) {
            sprintf_s(hex, "%02x", hash[i]);
            result += hex;
        }
        uint64 bits = 64 - 8;
        for (int i = 0; i < int(hashLen/2); ++i) {
            hi += (((uint64)hash[i]) << bits);
            bits -= 8;
        }
        bits = 64 - 8;
        for (int i = hashLen / 2; i < int(hashLen); ++i) {
            lo += (((uint64)hash[i]) << bits);
            bits -= 8;
        }
        CryptDestroyHash(hHash);
        CryptReleaseContext(hProv, 0);
        return true;
    }
    CryptDestroyHash(hHash);
    CryptReleaseContext(hProv, 0);
    return false;
}