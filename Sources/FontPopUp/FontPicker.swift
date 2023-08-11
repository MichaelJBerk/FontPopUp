//
//  FontPicker.swift
//  
//
//  Created by Michael Berk on 6/5/23.
//

import SwiftUI
//TODO: Fix menu item selection
///A control to select a font installed on the user's machine
public struct FontPicker: NSViewRepresentable {
	
	public init(font: Binding<NSFont?>, traitsFilter: NSFontTraitMask? = nil, fontMenu: NSMenu? = nil) {
		self._font = font
		self.traitsFilter = traitsFilter
		self.fontMenu = fontMenu
		if fontMenu == nil || font.wrappedValue == nil {
			let makeMenu = FontPopUpButton.makeMenu(familyName: self.font?.familyName, traitsFilter: traitsFilter)
			self.fontMenu = makeMenu.menu
		}
	}
	
	///The font menu to be displayed
	@State public var fontMenu: NSMenu? = nil
	///The currently selected font
	@Binding public var font: NSFont?
	
	///Restrict the list of font families to those with particular traits
	@State public var traitsFilter: NSFontTraitMask? = nil
	
	public func makeNSView(context: Context) -> FontPopUpButton {
		let menu = fontMenu
		let popup = FontPopUpButton(frame: .zero, callback: fontChanged(font:), menu: menu)
		return popup
	}
	
	func fontChanged(font: NSFont?) {
		self.font = font
	}
	
	public func updateNSView(_ nsView: FontPopUpButton, context: Context) {
		if self.font != nsView.selectedFont || traitsFilter != nsView.lastTraitsFilter || fontMenu != nsView.menu  {
			nsView.lastTraitsFilter = traitsFilter
			let makeMenu = FontPopUpButton.makeMenu(familyName: font?.familyName, traitsFilter: traitsFilter)
			nsView.menu = makeMenu.menu
			nsView.select(makeMenu.selectedItem)
		}
	}
}

struct FontPicker_Previews: PreviewProvider {
	static var font: NSFont? = nil
    static var previews: some View {
		FontPicker(font: .init(get: {font}, set: {font = $0}))
			.padding()
    }
}
