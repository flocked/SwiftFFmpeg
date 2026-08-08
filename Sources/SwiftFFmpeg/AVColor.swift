//
//  AVColor.swift
//
//
//  Created by Florian Zand on 07.08.26.
//

import CFFmpeg

/// A color represented by red, green, blue, and alpha components.
public struct AVColor: Hashable, Sendable, CustomStringConvertible {
    /// The red component.
    public var red: UInt8
    /// The green component.
    public var green: UInt8
    /// The blue component.
    public var blue: UInt8
    /// The alpha component.
    public var alpha: UInt8
    
    private let isRandom: Bool
    
    public var description: String {
        if let name = name {
            return "\(name) (\(red), \(green), \(blue), \(alpha))"
        }
        return "(\(red), \(green), \(blue), \(alpha))"
    }

    var rgbaBytes: [UInt8] {
        [red, green, blue, alpha]
    }

    /// Creates a color with the specified red, green, blue, and alpha components.
    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 255) {
        self.init(red, green, blue, alpha, false)
    }
    
    private init(_ red: UInt8, _ green: UInt8, _ blue: UInt8, _ alpha: UInt8, _ isRandom: Bool) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
        self.isRandom = isRandom
    }
    
    /// Creates a color with the specified color.
    public init?(name: String) {
        var rgba = [UInt8](repeating: 0, count: 4)
        let result = name.withCString { av_parse_color(&rgba, $0, -1, nil) }
        guard result >= 0 else { return nil }
        self.init(rgba[0], rgba[1], rgba[2], rgba[3], name == "random")
    }
    
    init(_ values: [UInt8], isRandom: Bool = false) {
        red = values[safe: 0] ?? 0
        green = values[safe: 1] ?? 0
        blue = values[safe: 2] ?? 0
        alpha = values[safe: 3] ?? .max
        self.isRandom = isRandom
    }
    
    /// Returns the color with the specified alpha value.
    public func withAlpha(_ alpha: UInt8) -> Self {
        var color = self
        color.alpha = alpha
        return color
    }
    
    /// The name of the color.
    public var name: String? {
        if isRandom { return "random" }
        guard alpha == 255 else { return nil }
        var index: Int32 = 0
        while true {
            var rgb: UnsafePointer<UInt8>?
            guard let cName = av_get_known_color_name(index, &rgb) else { return nil }
            if let rgb, rgb[0] == red, rgb[1] == green, rgb[2] == blue {
                return String(cString: cName)
            }
            index += 1
        }
    }
    
    /// The names of all colors recognized by `FFmpeg`.
    public static let knownNames: [String] = {
        var names: [String] = []
        var index: Int32 = 0
        while let name = av_get_known_color_name(index, nil) {
            names.append(String(cString: name))
            index += 1
        }
        return names
    }()
}

extension AVColor {
    /// The alice blue color (`"AliceBlue"`).
    public static let aliceBlue = Self(red: 240, green: 248, blue: 255, alpha: 255)
    /// The antique white color (`"AntiqueWhite"`).
    public static let antiqueWhite = Self(red: 250, green: 235, blue: 215, alpha: 255)
    /// The aqua color (`"Aqua"`).
    public static let aqua = Self(red: 0, green: 255, blue: 255, alpha: 255)
    /// The aquamarine color (`"Aquamarine"`).
    public static let aquamarine = Self(red: 127, green: 255, blue: 212, alpha: 255)
    /// The azure color (`"Azure"`).
    public static let azure = Self(red: 240, green: 255, blue: 255, alpha: 255)
    /// The beige color (`"Beige"`).
    public static let beige = Self(red: 245, green: 245, blue: 220, alpha: 255)
    /// The bisque color (`"Bisque"`).
    public static let bisque = Self(red: 255, green: 228, blue: 196, alpha: 255)
    /// The black color (`"Black"`).
    public static let black = Self(red: 0, green: 0, blue: 0, alpha: 255)
    /// The blanched almond color (`"BlanchedAlmond"`).
    public static let blanchedAlmond = Self(red: 255, green: 235, blue: 205, alpha: 255)
    /// The blue color (`"Blue"`).
    public static let blue = Self(red: 0, green: 0, blue: 255, alpha: 255)
    /// The blue violet color (`"BlueViolet"`).
    public static let blueViolet = Self(red: 138, green: 43, blue: 226, alpha: 255)
    /// The brown color (`"Brown"`).
    public static let brown = Self(red: 165, green: 42, blue: 42, alpha: 255)
    /// The burly wood color (`"BurlyWood"`).
    public static let burlyWood = Self(red: 222, green: 184, blue: 135, alpha: 255)
    /// The cadet blue color (`"CadetBlue"`).
    public static let cadetBlue = Self(red: 95, green: 158, blue: 160, alpha: 255)
    /// The chartreuse color (`"Chartreuse"`).
    public static let chartreuse = Self(red: 127, green: 255, blue: 0, alpha: 255)
    /// The chocolate color (`"Chocolate"`).
    public static let chocolate = Self(red: 210, green: 105, blue: 30, alpha: 255)
    /// The coral color (`"Coral"`).
    public static let coral = Self(red: 255, green: 127, blue: 80, alpha: 255)
    /// The cornflower blue color (`"CornflowerBlue"`).
    public static let cornflowerBlue = Self(red: 100, green: 149, blue: 237, alpha: 255)
    /// The cornsilk color (`"Cornsilk"`).
    public static let cornsilk = Self(red: 255, green: 248, blue: 220, alpha: 255)
    /// The crimson color (`"Crimson"`).
    public static let crimson = Self(red: 220, green: 20, blue: 60, alpha: 255)
    /// The cyan color (`"Cyan"`).
    public static let cyan = Self(red: 0, green: 255, blue: 255, alpha: 255)
    /// The dark blue color (`"DarkBlue"`).
    public static let darkBlue = Self(red: 0, green: 0, blue: 139, alpha: 255)
    /// The dark cyan color (`"DarkCyan"`).
    public static let darkCyan = Self(red: 0, green: 139, blue: 139, alpha: 255)
    /// The dark goldenrod color (`"DarkGoldenRod"`).
    public static let darkGoldenrod = Self(red: 184, green: 134, blue: 11, alpha: 255)
    /// The dark gray color (`"DarkGray"`).
    public static let darkGray = Self(red: 169, green: 169, blue: 169, alpha: 255)
    /// The dark green color (`"DarkGreen"`).
    public static let darkGreen = Self(red: 0, green: 100, blue: 0, alpha: 255)
    /// The dark khaki color (`"DarkKhaki"`).
    public static let darkKhaki = Self(red: 189, green: 183, blue: 107, alpha: 255)
    /// The dark magenta color (`"DarkMagenta"`).
    public static let darkMagenta = Self(red: 139, green: 0, blue: 139, alpha: 255)
    /// The dark olive green color (`"DarkOliveGreen"`).
    public static let darkOliveGreen = Self(red: 85, green: 107, blue: 47, alpha: 255)
    /// The dark orange color (`"Darkorange"`).
    public static let darkOrange = Self(red: 255, green: 140, blue: 0, alpha: 255)
    /// The dark orchid color (`"DarkOrchid"`).
    public static let darkOrchid = Self(red: 153, green: 50, blue: 204, alpha: 255)
    /// The dark red color (`"DarkRed"`).
    public static let darkRed = Self(red: 139, green: 0, blue: 0, alpha: 255)
    /// The dark salmon color (`"DarkSalmon"`).
    public static let darkSalmon = Self(red: 233, green: 150, blue: 122, alpha: 255)
    /// The dark sea green color (`"DarkSeaGreen"`).
    public static let darkSeaGreen = Self(red: 143, green: 188, blue: 143, alpha: 255)
    /// The dark slate blue color (`"DarkSlateBlue"`).
    public static let darkSlateBlue = Self(red: 72, green: 61, blue: 139, alpha: 255)
    /// The dark slate gray color (`"DarkSlateGray"`).
    public static let darkSlateGray = Self(red: 47, green: 79, blue: 79, alpha: 255)
    /// The dark turquoise color (`"DarkTurquoise"`).
    public static let darkTurquoise = Self(red: 0, green: 206, blue: 209, alpha: 255)
    /// The dark violet color (`"DarkViolet"`).
    public static let darkViolet = Self(red: 148, green: 0, blue: 211, alpha: 255)
    /// The deep pink color (`"DeepPink"`).
    public static let deepPink = Self(red: 255, green: 20, blue: 147, alpha: 255)
    /// The deep sky blue color (`"DeepSkyBlue"`).
    public static let deepSkyBlue = Self(red: 0, green: 191, blue: 255, alpha: 255)
    /// The dim gray color (`"DimGray"`).
    public static let dimGray = Self(red: 105, green: 105, blue: 105, alpha: 255)
    /// The dodger blue color (`"DodgerBlue"`).
    public static let dodgerBlue = Self(red: 30, green: 144, blue: 255, alpha: 255)
    /// The firebrick color (`"FireBrick"`).
    public static let firebrick = Self(red: 178, green: 34, blue: 34, alpha: 255)
    /// The floral white color (`"FloralWhite"`).
    public static let floralWhite = Self(red: 255, green: 250, blue: 240, alpha: 255)
    /// The forest green color (`"ForestGreen"`).
    public static let forestGreen = Self(red: 34, green: 139, blue: 34, alpha: 255)
    /// The fuchsia color (`"Fuchsia"`).
    public static let fuchsia = Self(red: 255, green: 0, blue: 255, alpha: 255)
    /// The gainsboro color (`"Gainsboro"`).
    public static let gainsboro = Self(red: 220, green: 220, blue: 220, alpha: 255)
    /// The ghost white color (`"GhostWhite"`).
    public static let ghostWhite = Self(red: 248, green: 248, blue: 255, alpha: 255)
    /// The gold color (`"Gold"`).
    public static let gold = Self(red: 255, green: 215, blue: 0, alpha: 255)
    /// The goldenrod color (`"GoldenRod"`).
    public static let goldenrod = Self(red: 218, green: 165, blue: 32, alpha: 255)
    /// The gray color (`"Gray"`).
    public static let gray = Self(red: 128, green: 128, blue: 128, alpha: 255)
    /// The green color (`"Green"`).
    public static let green = Self(red: 0, green: 128, blue: 0, alpha: 255)
    /// The green yellow color (`"GreenYellow"`).
    public static let greenYellow = Self(red: 173, green: 255, blue: 47, alpha: 255)
    /// The honeydew color (`"HoneyDew"`).
    public static let honeydew = Self(red: 240, green: 255, blue: 240, alpha: 255)
    /// The hot pink color (`"HotPink"`).
    public static let hotPink = Self(red: 255, green: 105, blue: 180, alpha: 255)
    /// The indian red color (`"IndianRed"`).
    public static let indianRed = Self(red: 205, green: 92, blue: 92, alpha: 255)
    /// The indigo color (`"Indigo"`).
    public static let indigo = Self(red: 75, green: 0, blue: 130, alpha: 255)
    /// The ivory color (`"Ivory"`).
    public static let ivory = Self(red: 255, green: 255, blue: 240, alpha: 255)
    /// The khaki color (`"Khaki"`).
    public static let khaki = Self(red: 240, green: 230, blue: 140, alpha: 255)
    /// The lavender color (`"Lavender"`).
    public static let lavender = Self(red: 230, green: 230, blue: 250, alpha: 255)
    /// The lavender blush color (`"LavenderBlush"`).
    public static let lavenderBlush = Self(red: 255, green: 240, blue: 245, alpha: 255)
    /// The lawn green color (`"LawnGreen"`).
    public static let lawnGreen = Self(red: 124, green: 252, blue: 0, alpha: 255)
    /// The lemon chiffon color (`"LemonChiffon"`).
    public static let lemonChiffon = Self(red: 255, green: 250, blue: 205, alpha: 255)
    /// The light blue color (`"LightBlue"`).
    public static let lightBlue = Self(red: 173, green: 216, blue: 230, alpha: 255)
    /// The light coral color (`"LightCoral"`).
    public static let lightCoral = Self(red: 240, green: 128, blue: 128, alpha: 255)
    /// The light cyan color (`"LightCyan"`).
    public static let lightCyan = Self(red: 224, green: 255, blue: 255, alpha: 255)
    /// The light goldenrod yellow color (`"LightGoldenRodYellow"`).
    public static let lightGoldenrodYellow = Self(red: 250, green: 250, blue: 210, alpha: 255)
    /// The light green color (`"LightGreen"`).
    public static let lightGreen = Self(red: 144, green: 238, blue: 144, alpha: 255)
    /// The light grey color (`"LightGrey"`).
    public static let lightGrey = Self(red: 211, green: 211, blue: 211, alpha: 255)
    /// The light pink color (`"LightPink"`).
    public static let lightPink = Self(red: 255, green: 182, blue: 193, alpha: 255)
    /// The light salmon color (`"LightSalmon"`).
    public static let lightSalmon = Self(red: 255, green: 160, blue: 122, alpha: 255)
    /// The light sea green color (`"LightSeaGreen"`).
    public static let lightSeaGreen = Self(red: 32, green: 178, blue: 170, alpha: 255)
    /// The light sky blue color (`"LightSkyBlue"`).
    public static let lightSkyBlue = Self(red: 135, green: 206, blue: 250, alpha: 255)
    /// The light slate gray color (`"LightSlateGray"`).
    public static let lightSlateGray = Self(red: 119, green: 136, blue: 153, alpha: 255)
    /// The light steel blue color (`"LightSteelBlue"`).
    public static let lightSteelBlue = Self(red: 176, green: 196, blue: 222, alpha: 255)
    /// The light yellow color (`"LightYellow"`).
    public static let lightYellow = Self(red: 255, green: 255, blue: 224, alpha: 255)
    /// The lime color (`"Lime"`).
    public static let lime = Self(red: 0, green: 255, blue: 0, alpha: 255)
    /// The lime green color (`"LimeGreen"`).
    public static let limeGreen = Self(red: 50, green: 205, blue: 50, alpha: 255)
    /// The linen color (`"Linen"`).
    public static let linen = Self(red: 250, green: 240, blue: 230, alpha: 255)
    /// The magenta color (`"Magenta"`).
    public static let magenta = Self(red: 255, green: 0, blue: 255, alpha: 255)
    /// The maroon color (`"Maroon"`).
    public static let maroon = Self(red: 128, green: 0, blue: 0, alpha: 255)
    /// The medium aquamarine color (`"MediumAquaMarine"`).
    public static let mediumAquamarine = Self(red: 102, green: 205, blue: 170, alpha: 255)
    /// The medium blue color (`"MediumBlue"`).
    public static let mediumBlue = Self(red: 0, green: 0, blue: 205, alpha: 255)
    /// The medium orchid color (`"MediumOrchid"`).
    public static let mediumOrchid = Self(red: 186, green: 85, blue: 211, alpha: 255)
    /// The medium purple color (`"MediumPurple"`).
    public static let mediumPurple = Self(red: 147, green: 112, blue: 216, alpha: 255)
    /// The medium sea green color (`"MediumSeaGreen"`).
    public static let mediumSeaGreen = Self(red: 60, green: 179, blue: 113, alpha: 255)
    /// The medium slate blue color (`"MediumSlateBlue"`).
    public static let mediumSlateBlue = Self(red: 123, green: 104, blue: 238, alpha: 255)
    /// The medium spring green color (`"MediumSpringGreen"`).
    public static let mediumSpringGreen = Self(red: 0, green: 250, blue: 154, alpha: 255)
    /// The medium turquoise color (`"MediumTurquoise"`).
    public static let mediumTurquoise = Self(red: 72, green: 209, blue: 204, alpha: 255)
    /// The medium violet red color (`"MediumVioletRed"`).
    public static let mediumVioletRed = Self(red: 199, green: 21, blue: 133, alpha: 255)
    /// The midnight blue color (`"MidnightBlue"`).
    public static let midnightBlue = Self(red: 25, green: 25, blue: 112, alpha: 255)
    /// The mint cream color (`"MintCream"`).
    public static let mintCream = Self(red: 245, green: 255, blue: 250, alpha: 255)
    /// The misty rose color (`"MistyRose"`).
    public static let mistyRose = Self(red: 255, green: 228, blue: 225, alpha: 255)
    /// The moccasin color (`"Moccasin"`).
    public static let moccasin = Self(red: 255, green: 228, blue: 181, alpha: 255)
    /// The navajo white color (`"NavajoWhite"`).
    public static let navajoWhite = Self(red: 255, green: 222, blue: 173, alpha: 255)
    /// The navy color (`"Navy"`).
    public static let navy = Self(red: 0, green: 0, blue: 128, alpha: 255)
    /// The old lace color (`"OldLace"`).
    public static let oldLace = Self(red: 253, green: 245, blue: 230, alpha: 255)
    /// The olive color (`"Olive"`).
    public static let olive = Self(red: 128, green: 128, blue: 0, alpha: 255)
    /// The olive drab color (`"OliveDrab"`).
    public static let oliveDrab = Self(red: 107, green: 142, blue: 35, alpha: 255)
    /// The orange color (`"Orange"`).
    public static let orange = Self(red: 255, green: 165, blue: 0, alpha: 255)
    /// The orange red color (`"OrangeRed"`).
    public static let orangeRed = Self(red: 255, green: 69, blue: 0, alpha: 255)
    /// The orchid color (`"Orchid"`).
    public static let orchid = Self(red: 218, green: 112, blue: 214, alpha: 255)
    /// The pale goldenrod color (`"PaleGoldenRod"`).
    public static let paleGoldenrod = Self(red: 238, green: 232, blue: 170, alpha: 255)
    /// The pale green color (`"PaleGreen"`).
    public static let paleGreen = Self(red: 152, green: 251, blue: 152, alpha: 255)
    /// The pale turquoise color (`"PaleTurquoise"`).
    public static let paleTurquoise = Self(red: 175, green: 238, blue: 238, alpha: 255)
    /// The pale violet red color (`"PaleVioletRed"`).
    public static let paleVioletRed = Self(red: 216, green: 112, blue: 147, alpha: 255)
    /// The papaya whip color (`"PapayaWhip"`).
    public static let papayaWhip = Self(red: 255, green: 239, blue: 213, alpha: 255)
    /// The peach puff color (`"PeachPuff"`).
    public static let peachPuff = Self(red: 255, green: 218, blue: 185, alpha: 255)
    /// The peru color (`"Peru"`).
    public static let peru = Self(red: 205, green: 133, blue: 63, alpha: 255)
    /// The pink color (`"Pink"`).
    public static let pink = Self(red: 255, green: 192, blue: 203, alpha: 255)
    /// The plum color (`"Plum"`).
    public static let plum = Self(red: 221, green: 160, blue: 221, alpha: 255)
    /// The powder blue color (`"PowderBlue"`).
    public static let powderBlue = Self(red: 176, green: 224, blue: 230, alpha: 255)
    /// The purple color (`"Purple"`).
    public static let purple = Self(red: 128, green: 0, blue: 128, alpha: 255)
    /// The red color (`"Red"`).
    public static let red = Self(red: 255, green: 0, blue: 0, alpha: 255)
    /// The rosy brown color (`"RosyBrown"`).
    public static let rosyBrown = Self(red: 188, green: 143, blue: 143, alpha: 255)
    /// The royal blue color (`"RoyalBlue"`).
    public static let royalBlue = Self(red: 65, green: 105, blue: 225, alpha: 255)
    /// The saddle brown color (`"SaddleBrown"`).
    public static let saddleBrown = Self(red: 139, green: 69, blue: 19, alpha: 255)
    /// The salmon color (`"Salmon"`).
    public static let salmon = Self(red: 250, green: 128, blue: 114, alpha: 255)
    /// The sandy brown color (`"SandyBrown"`).
    public static let sandyBrown = Self(red: 244, green: 164, blue: 96, alpha: 255)
    /// The sea green color (`"SeaGreen"`).
    public static let seaGreen = Self(red: 46, green: 139, blue: 87, alpha: 255)
    /// The seashell color (`"SeaShell"`).
    public static let seashell = Self(red: 255, green: 245, blue: 238, alpha: 255)
    /// The sienna color (`"Sienna"`).
    public static let sienna = Self(red: 160, green: 82, blue: 45, alpha: 255)
    /// The silver color (`"Silver"`).
    public static let silver = Self(red: 192, green: 192, blue: 192, alpha: 255)
    /// The sky blue color (`"SkyBlue"`).
    public static let skyBlue = Self(red: 135, green: 206, blue: 235, alpha: 255)
    /// The slate blue color (`"SlateBlue"`).
    public static let slateBlue = Self(red: 106, green: 90, blue: 205, alpha: 255)
    /// The slate gray color (`"SlateGray"`).
    public static let slateGray = Self(red: 112, green: 128, blue: 144, alpha: 255)
    /// The snow color (`"Snow"`).
    public static let snow = Self(red: 255, green: 250, blue: 250, alpha: 255)
    /// The spring green color (`"SpringGreen"`).
    public static let springGreen = Self(red: 0, green: 255, blue: 127, alpha: 255)
    /// The steel blue color (`"SteelBlue"`).
    public static let steelBlue = Self(red: 70, green: 130, blue: 180, alpha: 255)
    /// The tan color (`"Tan"`).
    public static let tan = Self(red: 210, green: 180, blue: 140, alpha: 255)
    /// The teal color (`"Teal"`).
    public static let teal = Self(red: 0, green: 128, blue: 128, alpha: 255)
    /// The thistle color (`"Thistle"`).
    public static let thistle = Self(red: 216, green: 191, blue: 216, alpha: 255)
    /// The tomato color (`"Tomato"`).
    public static let tomato = Self(red: 255, green: 99, blue: 71, alpha: 255)
    /// The turquoise color (`"Turquoise"`).
    public static let turquoise = Self(red: 64, green: 224, blue: 208, alpha: 255)
    /// The violet color (`"Violet"`).
    public static let violet = Self(red: 238, green: 130, blue: 238, alpha: 255)
    /// The wheat color (`"Wheat"`).
    public static let wheat = Self(red: 245, green: 222, blue: 179, alpha: 255)
    /// The white color (`"White"`).
    public static let white = Self(red: 255, green: 255, blue: 255, alpha: 255)
    /// The white smoke color (`"WhiteSmoke"`).
    public static let whiteSmoke = Self(red: 245, green: 245, blue: 245, alpha: 255)
    /// The yellow color (`"Yellow"`).
    public static let yellow = Self(red: 255, green: 255, blue: 0, alpha: 255)
    /// The yellow green color (`"YellowGreen"`).
    public static let yellowGreen = Self(red: 154, green: 205, blue: 50, alpha: 255)
}
