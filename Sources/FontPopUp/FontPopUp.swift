import AppKit

///A callback that can be performed when a font has been selected.
public typealias FontChangeHandler = ((NSFont?) -> ())

///An NSPopUpButton used for selecting a font installed on the user's machine
///
///- Important: The popup button won't have the proper intrinsic content size when it initalized, since it must load all the menu items asyncronously. As such, it's recommended to use Auto Layout or the like to adjust the width when it is added to the view hierarchy, so that it won't be the wrong size until the user selects an item.
public class FontPopUpButton: NSPopUpButton {
	
	private let fontManager = NSFontManager.shared
	private let defaultItem = NSMenuItem(title: "Default", action: nil, keyEquivalent: "")
	
	///Restrict the list of font families to those with particular traits
	public var fontTraitsFilter: NSFontTraitMask? = nil
	
	///The currently selected font
	public var selectedFont: NSFont? {
		didSet {
			if let selectedFont,
			   let family = selectedFont.familyName,
			   let fontItem = self.item(withTitle: family) {
				self.select(fontItem)
			} else {
				self.select(defaultItem)
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
	public init(frame buttonFrame: NSRect = .infinite, callback: FontChangeHandler? = nil) {
		self.onFontChanged = callback ?? {_ in}
		super.init(frame: buttonFrame, pullsDown: false)
		setup()
	}
	
	required init?(coder: NSCoder) {
		self.onFontChanged = {_ in}
		super.init(coder: coder)
		setup()
	}
	
	///Callback to perform when the user has selected a font
	public var onFontChanged: FontChangeHandler
	
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
		let familyName = self.font?.familyName
		
		DispatchQueue.global(qos: .userInitiated).async {
			var families = self.fontManager.availableFontFamilies
			if let fontTraitsFilter = self.fontTraitsFilter {
				families = self.fontManager.availableFontNames(with: fontTraitsFilter) ?? families
			}
			for family in families {
				if let font = self.fontManager.font(withFamily: family, traits: [], weight: 5, size: NSFont.systemFontSize) {
					let fontItem = NSMenuItem(title: family, action: nil, keyEquivalent: "")
					let attStr = NSAttributedString(string: family, attributes: [
						.font: font
					])
					fontItem.attributedTitle = attStr
					fontItem.representedObject = font
					fontMenu.addItem(fontItem)
					if familyName == family {
						DispatchQueue.main.async {
							self.select(fontItem)
						}
					}
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

