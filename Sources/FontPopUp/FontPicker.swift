//
//  FontPicker.swift
//  
//
//  Created by Michael Berk on 6/5/23.
//

import SwiftUI

///A control to select a font installed on the user's machine
public struct FontPicker: NSViewRepresentable {
	///The currently selected font
	@Binding public var font: NSFont?
	
	///Restrict the list of font families to those with particular traits
	@State public var traitsFilter: NSFontTraitMask? = nil
	
	public func makeNSView(context: Context) -> FontPopUpButton {
		let popup = FontPopUpButton(frame: .zero, callback: fontChanged(font:))
		popup.fontTraitsFilter = traitsFilter
		return popup
	}
	
	func fontChanged(font: NSFont?) {
		self.font = font
	}
	
	public func updateNSView(_ nsView: FontPopUpButton, context: Context) {
		nsView.selectedFont = font
		nsView.fontTraitsFilter = traitsFilter
	}
}

struct FontPicker_Previews: PreviewProvider {
	static var font: NSFont? = nil
    static var previews: some View {
		FontPicker(font: .init(get: {font}, set: {font = $0}))
			.padding()
    }
}
