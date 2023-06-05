import AppKit

///An NSPopUpButton used for selecting a font installed on the user's machine
class FontPopUpButton: NSPopUpButton {
	///A callback that can be performed when a font has been selected.
	public typealias FontChangeCallback = ((NSFont?) -> ())
	
	private let fontManager = NSFontManager.shared
	private let defaultItem = NSMenuItem(title: "Default", action: nil, keyEquivalent: "")
	
	///Restrict the list of font families to those with particular traits
	public var fontTraitsFilter: NSFontTraitMask? = nil
	
	///The currently selected font
	var selectedFont: NSFont? {
		didSet {
			if let selectedFont,
			   let family = selectedFont.familyName,
			   let fontItem = self.item(withTitle: family) {
				self.select(fontItem)
			} else {
				//selected font doesn't exist on device
			}
		}
	}
	
	/// Returns a FontPopUpButton object initialized to the specified dimensions.
	/// - Parameters:
	///   - buttonFrame: The frame rectangle for the button, specified in the parent view's coordinate system.
	///   - flag: true if you want the receiver to display a pull-down menu; otherwise, false if you want it to display a pop-up menu.
	///   - callback: Callback to perform when the user has selected a font
	/// - Returns: An initialized FontPopUpButton object, or nil if the object could not be initialized.
	init(frame buttonFrame: NSRect, pullsDown flag: Bool, callback: FontChangeCallback? = nil) {
		self.onFontChanged = callback ?? {_ in}
		super.init(frame: buttonFrame, pullsDown: flag)
		setup()
	}
	
	required init?(coder: NSCoder) {
		self.onFontChanged = {_ in}
		super.init(coder: coder)
		setup()
	}
	
	var onFontChanged: FontChangeCallback
	
	func setup() {
		self.target = self
		self.action = #selector(selectedItem(_:))
		let fontMenu = NSMenu()
		
		let separator = NSMenuItem.separator()
		
		fontMenu.addItem(defaultItem)
		fontMenu.addItem(separator)
		self.menu = fontMenu
		if self.selectedFont == nil {
			self.select(defaultItem)
		}
		var families = fontManager.availableFontFamilies
		if let fontTraitsFilter {
			families = fontManager.availableFontNames(with: fontTraitsFilter) ?? families
		}
		for family in fontManager.availableFontFamilies {
			if let font = fontManager.font(withFamily: family, traits: [], weight: 5, size: NSFont.systemFontSize) {
				let fontItem = NSMenuItem(title: family, action: nil, keyEquivalent: "")
				let attStr = NSAttributedString(string: family, attributes: [
					.font: font
				])
				fontItem.attributedTitle = attStr
				fontItem.representedObject = font
				fontMenu.addItem(fontItem)
				if self.font?.familyName == family {
					self.select(fontItem)
				}
			}
		}
		
	}
	
	@objc func selectedItem(_ sender: NSPopUpButton) {
		guard let selectedItem = sender.selectedItem else {return}
		if selectedItem == defaultItem {
			self.selectedFont = nil
		} else {
			self.selectedFont = selectedItem.representedObject as? NSFont
		}
		onFontChanged(self.selectedFont)
	}
}

