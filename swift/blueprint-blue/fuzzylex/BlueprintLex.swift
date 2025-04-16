public protocol ILexicalComparitor { 
    let wkey: UInt16! { get }
    let Lex: String! { get }
    let Mod: String! { get }
    let ELex: UInt8[] { get }
    let EMod: UInt8[] { get }
    let PLex: String! { get }
    let PMod: String! { get }
}

open class BlueprintLemma : ILexicalComparitor { 
    private var Lemma: String!
    private var ELemma: UInt8[]
    private var PLemma: String!

    public private(set) static var MaxELemmaLen: UInt8 = 0
    public private(set) var wkey: UInt16!

    public var Lex: String! {
        get {
            return self.Lemma
        }
    }

    public var Mod: String! {
        get {
            return self.Lemma
        }
    }

    public var ELex: UInt8[] {
        get {
            return self.ELemma
        }
    }

    public var PLex: String! {
        get {
            return self.PLemma
        }
    }

    public var EMod: UInt8[] {
        get {
            return self.ELemma
        }
    }

    public var PMod: String! {
        get {
            return self.PLemma
        }
    }

    public private(set) static var MaxLen: UInt8 = 0
    public private(set) static var LemmaPartition: Dictionary<UInt8,Dictionary<UInt16!,ILexicalComparitor!>!>! = ()
    public private(set) static var OOVLemma: Dictionary<UInt16!,String!>! = ()
    public private(set) static var OOVMap: Dictionary<String!,BlueprintLemma!>! = ()

    public static func Initialize(_ avxobjects: AVXLib.ObjectTable!) {
        if BlueprintLemma.OOVMap.Count == 0 {
            for key in avxobjects.oov.Keys {
                var entry = avxobjects.oov.GetEntry(key)
                if entry.valid {
                    BlueprintLemma(key, entry.oov.text.ToString())
                }
            }
            BlueprintLex.Initialize(avxobjects)
            //  safe reciprocle inits
        }
    }

    private init(_ key: UInt16!, _ text: String!) {
        if (text.Length > 0) && (key != 0) {
            self.wkey = key
            self.Lemma = text
            var lemma = NUPhoneGen(text)
            self.PLemma = lemma.Phonetic
            var elen = self.PLemma.Length
            if (elen > 0) && (elen <= UInt8.MaxValue) {
                var blen = (elen as? UInt8)
                if elen > BlueprintLemma.MaxELemmaLen {
                    BlueprintLemma.MaxELemmaLen = blen
                }
                self.ELemma = lemma.Embeddings
                if !BlueprintLemma.LemmaPartition.ContainsKey(blen) {
                    BlueprintLemma.LemmaPartition[blen] = ()
                }
                BlueprintLemma.LemmaPartition[blen][self.wkey] = self
            } else {
                self.ELemma = UInt8[](count: 0)
            }
        } else {
            self.wkey = 0
            self.Lemma = String.Empty
            self.PLemma = String.Empty
            self.ELemma = UInt8[](count: 0)
        }
    }
}

open class BlueprintLex : ILexicalComparitor { 
    private var Display: String!
    private var emod: UInt8[]
    private var pmod: String?

    public private(set) static var MaxELexLen: UInt8 = 0
    public private(set) static var MaxEModLen: UInt8 = 0
    public private(set) static var LexGlobal: Dictionary<UInt16!,BlueprintLex!>! = ()
    public private(set) static var LexPartition: Dictionary<UInt8,Dictionary<UInt16!,BlueprintLex!>!>! = ()
    public private(set) static var ModPartition: Dictionary<UInt8,Dictionary<UInt16!,BlueprintLex!>!>! = ()
    public private(set) static var LexMap: Dictionary<String!,BlueprintLex!>! = ()
    public private(set) static var ModMap: Dictionary<String!,BlueprintLex!>! = ()
    public private(set) var wkey: UInt16!
    public private(set) var Entities: UInt16!
    public private(set) var POS: ReadOnlyMemory<UInt32!>!
    public private(set) var Lex: String!
    public private(set) var Mod: String!
    public private(set) var ModernOrthography: Bool = false
    public private(set) var ModernPhonetics: Bool = false
    public private(set) var ELex: UInt8[]
    public private(set) var PLex: String!

    public var EMod: UInt8[] {
        get {
            return (self.emod != nil ? self.emod : self.ELex)
        }
    }

    public var PMod: String! {
        get {
            return (self.pmod != nil ? self.pmod : self.PLex)
        }
    }

    public static func Initialize(_ avxobjects: AVXLib.ObjectTable!) {
        if BlueprintLex.LexGlobal.Count == 0 {
            var cnt: UInt16! = avxobjects.lexicon.RecordCount
            for wkey in 1 ... cnt - 1 {
                __try {
                    var record = avxobjects.lexicon.GetRecord(wkey)
                    if record.valid {
                        BlueprintLex(wkey, record.entry)
                    }
                }
                __catch {
                    Console.WriteLine(wkey.ToString())
                }
            }
            BlueprintLemma.Initialize(avxobjects)
            //  safe reciprocle inits
        }
    }

    private init(_ wkey: UInt16!, _ entry: AVXLib.Memory.Lexicon!) {
        self.wkey = wkey
        self.Lex = LEXICON.ToSearchString(entry)
        self.Mod = (LEXICON.IsHyphenated(entry) ? LEXICON.ToSearchString(entry) : LEXICON.ToModernString(entry))
        if !LEXICON.IsModernSameAsDisplay(entry) {
            self.Mod = self.Mod.Replace(" ", "")
        }
        //  e.g. vilest => most vile
        self.ModernOrthography = !LEXICON.IsModernSameAsDisplay(entry)
        self.Display = LEXICON.ToDisplayString(entry)
        self.POS = entry.POS
        self.Entities = entry.Entities
        var search = NUPhoneGen(self.Lex)
        var elexLen = (search.Phonetic.Length as? UInt8)
        self.PLex = search.Phonetic
        self.ELex = search.Embeddings
        var emodLen: UInt8 = 0
        if self.ModernOrthography {
            var modern = NUPhoneGen(self.Mod)
            emodLen = (modern.Phonetic.Length as? UInt8)
            self.ModernPhonetics = search.Phonetic != modern.Phonetic
            self.pmod = (self.ModernPhonetics ? modern.Phonetic : nil)
            self.emod = (self.ModernPhonetics ? modern.Embeddings : nil)
        } else {
            emodLen = elexLen
            self.ModernPhonetics = false
            self.pmod = nil
            self.emod = nil
        }
        BlueprintLex.LexGlobal[self.wkey] = self
        BlueprintLex.LexMap[self.Lex] = self
        BlueprintLex.ModMap[self.Mod] = self
        if (elexLen > 0) && (elexLen <= UInt8.MaxValue) {
            if !BlueprintLex.LexPartition.ContainsKey(elexLen) {
                BlueprintLex.LexPartition[elexLen] = ()
            }
            BlueprintLex.LexPartition[elexLen][self.wkey] = self
            if elexLen > BlueprintLex.MaxELexLen {
                BlueprintLex.MaxELexLen = elexLen
            }
        }
        if (emodLen > 0) && (emodLen <= UInt8.MaxValue) {
            if !BlueprintLex.ModPartition.ContainsKey(emodLen) {
                BlueprintLex.ModPartition[emodLen] = ()
            }
            BlueprintLex.ModPartition[emodLen][self.wkey] = self
            if emodLen > BlueprintLex.MaxEModLen {
                BlueprintLex.MaxEModLen = emodLen
            }
        }
    }
}

