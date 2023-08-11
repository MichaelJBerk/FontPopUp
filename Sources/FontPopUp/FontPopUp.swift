import AppKit

///A callback that can be performed when a font has been selected.
public typealias FontChangeHandler = ((NSFont?) -> ())

///An NSPopUpButton used for selecting a font installed on the user's machine
///
///- Important: The popup button won't have the proper intrinsic content size when it initalized, since it must load all the menu items asyncronously. As such, it's recommended to use Auto Layout or the like to adjust the width when it is added to the view hierarchy, so that it won't be the wrong size until the user selects an item.
public class FontPopUpButton: NSPopUpButton {
	
	private static let fontManager = NSFontManager.shared
	
	internal static var defaultItem: NSMenuItem {
		NSMenuItem(title: "Default", action: nil, keyEquivalent: "")
	}
	
	///The currently selected font
	public var selectedFont: NSFont? {
		didSet {
			if let selectedFont,
			   let family = selectedFont.familyName,
			   let fontItem = self.item(withTitle: family) {
				self.select(fontItem)
			} else {
				self.selectItem(at: 0)
				//selected font doesn't exist on device
			}
		}
	}
	
	///A Boolean value indicating whether the button displays a pull-down or pop-up menu. Always returns false.
	override public var pullsDown: Bool {
		get {return false}
		set {}
	}
	
	/// Returns a FontPopUpButton object initialized to the specified dimensions.
	/// - Parameters:
	///   - buttonFrame: The frame rectangle for the button, specified in the parent view's coordinate system.
	///   - callback: Callback to perform when the user has selected a font
	/// - Returns: An initialized FontPopUpButton object, or nil if the object could not be initialized.
	public init(frame buttonFrame: NSRect = .infinite, callback: FontChangeHandler? = nil, menu: NSMenu? = nil) {
		self.onFontChanged = callback ?? {_ in}
		super.init(frame: .init(), pullsDown: false)
		setup(menu: menu)
	}
	
	required init?(coder: NSCoder) {
		self.onFontChanged = {_ in}
		super.init(coder: coder)
		setup()
	}
	
	///Callback to perform when the user has selected a font
	public var onFontChanged: FontChangeHandler
	
	func setup(menu: NSMenu? = nil) {
		self.target = self
		self.action = #selector(selectedItem(_:))
		let familyName = self.font?.familyName
		if let menu = menu {
			self.menu = menu
		} else {
			let makeMenu = Self.makeMenu(familyName: familyName)
			self.menu = makeMenu.0
			if let item = makeMenu.selectedItem {
				self.select(item)
			} else {
				self.selectItem(at: 0)
			}
		}
	}
	
	/// Generate the font menu to be used with a FontPopUpButton
	///
	/// Since adding the fonts to the menu when the view is initalized causes a bit of a delay, you can use this method to generate the menu before the button needs to be presented, and provide that to the initalizer.
	/// - Parameters:
	///   - familyName: Name of the font family that shouldbe selected
	///   - traitsFilter: A NSFontTraitMask to restrict the list of fonts
	/// - Returns: A tuple containing the `menu` generated, and the `selectedItem`
	public static func makeMenu(familyName: String?, traitsFilter: NSFontTraitMask? = nil) -> (menu: NSMenu, selectedItem: NSMenuItem?) {
		let fontMenu = NSMenu()
		
		let separator = NSMenuItem.separator()
		
		fontMenu.addItem(defaultItem)
		fontMenu.addItem(separator)
		var families = Self.fontManager.availableFontFamilies
		if let traitsFilter {
			families = Self.fontManager.availableFontNames(with: traitsFilter) ?? families
		}
		var selectedItem: NSMenuItem? = nil
		for family in families {
			if let font = Self.fontManager.font(withFamily: family, traits: [], weight: 5, size: NSFont.systemFontSize) {
				let fontItem = NSMenuItem(title: family, action: nil, keyEquivalent: "")
				let attStr = NSAttributedString(string: family, attributes: [
					.font: font
				])
				fontItem.attributedTitle = attStr
				fontItem.representedObject = font
				fontMenu.addItem(fontItem)
				if familyName == family {
					selectedItem = fontItem
				}
			}
		}
		return (fontMenu, selectedItem)
	}
	
	@objc func selectedItem(_ sender: NSPopUpButton) {
		if let selectedItem = sender.selectedItem, selectedItem.title != Self.defaultItem.title {
			self.selectedFont = selectedItem.representedObject as? NSFont
		} else {
			self.selectedFont = nil
		}
		onFontChanged(self.selectedFont)
	}
	
	
	///Used to keep track of changes to font traits in SwiftUI
	internal var lastTraitsFilter: NSFontTraitMask?
}

