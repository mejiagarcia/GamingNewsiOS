import SwiftUI

extension NewsCategory {
	var title: LocalizedStringKey {
		switch self {
			case .all: "category.all"
			case .sony: "category.playstation"
			case .microsoft: "category.xbox"
			case .nintendo: "category.nintendo"
			case .pc: "category.pc"
		}
	}
}
