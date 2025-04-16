open class LexiconIPA { 
	private static var SELF: LexiconIPA? = nil
	private var newlines: Char[]

	public static var Instance: LexiconIPA! {
		get {
			if SELF == nil {
				SELF = LexiconIPA()
			}
			return SELF
		}
	}

	public private(set) var ipa_primatives: Dictionary<String!,String![]>!

	private init(_ home: String? = nil) {
		LexiconIPA.SELF = self
		self.ipa_primatives = ()
		var first: Int32 = 0
		var last: Int32 = -1
		var len: Int32 = en_US.Contents.Length
		__try {
			repeat {last = (len > first ? en_US.Contents.IndexOfAny(newlines, first + 1) : first)
				if last < 0 {
					break
				}
				if last > first {
					var line: String! = en_US.Contents.Substring(first, last - first).Trim()
					if line.Length > 0 {
						var parts = line.Split("/", 2)
						if parts.Length < 2 {
							continue
						}
						parts[0] = parts[0].Trim()
						if parts[0].Length < 1 {
							continue
						}
						var variants = parts[1].Split(",")
						for v in 0 ... variants.Length - 1 {
							var variant = variants[v].Trim()
							if variant.EndsWith("/") && (variant.StartsWith("/") || (v == 0)) {
								variants[v] = Features.Instance.NormalizeIntoNUPhone(variant.Replace("/", ""))
							} else {
								System.Console.WriteLine(line)
								goto bad_record
							}
						}
						self.ipa_primatives[parts[0]] = variants
						{
							bad_record:

						}
					}
				}
				while (first < len) && ((en_US.Contents[first] == "\n") || (en_US.Contents[first] == "\r")) {
					first = last + 1


					inc(first)
				}} while first < len}
		__catch {
			System.Console.WriteLine("IO Error encountered")
			self.ipa_primatives.Clear()
		}
	}

	// obsolete method is likely just cruft
	public static func GetMicrosoftStoreFolder(_ name: String!) -> String! {
		var appdata: String! = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "AV-Bible")
		if !Directory.Exists(appdata) {
			Directory.CreateDirectory(appdata)
		}
		var folder: String! = Path.Combine(appdata, name)
		if !Directory.Exists(folder) {
			Directory.CreateDirectory(folder)
		}
		return folder
	}

	private static func OBSOLETE_DownloadFiles(_ name: String!, _ timeout_seconds: UInt8 = 20) -> String! {
		var task = OBSOLETE_DownloadFilesAsync(name)
		task.Wait(timeout_seconds * 1024)
		if task.IsCompleted {
			return task.Result
		}
		return String.Empty
	}

	private static func OBSOLETE_DownloadFilesAsync(_ name: String!) -> Task<String!>! {
		var url: String! = "https://github.com/kwonus/AV-Bible/raw/refs/heads/main/Release-9.25.2"
		var zip: String! = url + "/" + name + ".zip"
		var path: String! = Path.GetDirectoryName(GetMicrosoftStoreFolder(name))
		__using let client = HttpClient() {
		__using let memoryStream = MemoryStream() {
		//  Download the zip file into the memory stream
		var zipData: UInt8[] = __await client.GetByteArrayAsync(url)
		__await memoryStream.WriteAsync(zipData, 0, zipData.Length)
		memoryStream.Position = 0
		//  Reset the stream position to the beginning
		//  Extract the contents of the zip file directly from the memory stream
		__using let archive = ZipArchive(memoryStream, ZipArchiveMode.Read) {
		for entry in archive.Entries {
			var destinationPath: String! = Path.Combine(path, entry.FullName)
			//  Ensure the directory structure is in place
			if entry.FullName.EndsWith("/") {
				Directory.CreateDirectory(destinationPath)
				continue
			}
			//  Extract the file
			__using let entryStream = entry.Open() {
			__using let fileStream = FileStream(destinationPath, FileMode.Create, FileAccess.Write) {
			__await entryStream.CopyToAsync(fileStream)
			}
			}
		}
		}
		}
		}
		return path
	}

	// Test for folder only when file is null (otherwise, file must exist within folder)
	private static func OBSOLETE_GetProgramDirDefault(_ collection: String!, _ file: String? = nil) -> String! {
		var dir: String! = GetMicrosoftStoreFolder(collection)
		if System.IO.Directory.Exists(dir) {
			if file == nil {
				return dir
			}
			var item: String! = Path.Combine(collection, file)
			if !System.IO.File.Exists(item) {
				OBSOLETE_DownloadFiles(item)
			}
			if System.IO.File.Exists(item) {
				return item
			}
		}
		return String.Empty
	}
}

