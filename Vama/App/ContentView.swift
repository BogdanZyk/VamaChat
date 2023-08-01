//
//  ContentView.swift
//  Vama
//
//  Created by Bogdan Zykov on 31.07.2023.
//

import SwiftUI

struct CustomColorCategory: Identifiable, Hashable, Equatable {
    var id = UUID()
    
    let colors: [CustomColor]
    let name: String
}


struct CustomColor: Identifiable, Hashable {
    var id = UUID()
    
    let color: Color
    let name: String
}


struct ContentView: View {
    

    var colorsCategories: [CustomColorCategory] = [
        CustomColorCategory(colors: [
            CustomColor(color: .red, name: "red"),
            CustomColor(color: .blue, name: "blue"),
            CustomColor(color: .yellow, name: "yellow")
        ], name: "common"),
        CustomColorCategory(colors: [
            CustomColor(color: .cyan, name: "cyan"),
            CustomColor(color: .mint, name: "mint"),
            CustomColor(color: .accentColor, name: "accent")
        ], name: "specific"),
    ]
    @State var selectedCategory: CustomColorCategory?
    @State var selectedColor: CustomColor?
//    @State var pathCategory: NavigationPath = NavigationPath()
//    @State var pathColor: NavigationPath = NavigationPath()
    
    var body: some View {
        Group {
            //if horizontalSizeClass == .regular {
                NavigationSplitView {
                    List(colorsCategories,
                         selection: $selectedCategory) { category in
                        NavigationLink(value: category) { // does not work with List selection option, presents just for visual style of selection provided by Split View sidebar
                            Text(category.name)
                        }
                    }
                         .navigationTitle("Categories")
                } content: {
                    CategoryView(category: selectedCategory,
                                 colorSelection: $selectedColor)
                } detail: {
                    DetailView(color: selectedColor)
                }
//            } else {
//                NavigationSplitView {
//                    List(colorsCategories,
//                         selection: $selectedCategory) { category in
//                        NavigationLink(value: category) { // does not work with List selection option, presents just for visual style of selection provided by Split View sidebar
//                            Text(category.name)
//                        }
//                    }
//                         .navigationTitle("Categories")
//                } detail: {
//                    NavigationStack {
//                        CategoryView(category: selectedCategory,
//                                     colorSelection: $selectedColor)
//                    }
//                }
//            }
        }
        .onChange(of: selectedCategory) { newValue in
            selectedColor = nil
        }
    }
}

struct CategoryView: View {
    
    var category: CustomColorCategory?
    @Binding var colorSelection: CustomColor?
    //@Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        Group {
            //if horizontalSizeClass == .regular {
                List(category?.colors ?? [], selection: $colorSelection) { color in
                    row(color: color)
                }
//            } else {
//                List(category?.colors ?? []) { color in
//                    row(color: color)
//                }
//            }
        }
//        .navigationDestination(for: CustomColor.self) { color in
//            DetailView(color: color)
//        }
        .navigationTitle(category?.name ?? "")
    }
    
    @ViewBuilder
    func row(color: CustomColor) -> some View {
        NavigationLink(value: color) {
            HStack {
                Rectangle()
                    .fill(color.color)
                    .frame(width: 20, height: 20)
                Text(color.name)
            }
        }
    }
    
}

struct DetailView: View {
    let color: CustomColor?
    
    var body: some View {
        NavigationStack{
            VStack {
                if let color {
                    Rectangle()
                        .fill(color.color)
                        .frame(width: 200, height: 200)
                    NavigationLink(color.name, value: color.name)
          
                } else {
                    EmptyView()
                }
            }
            .navigationTitle(color?.name ?? "")
            .navigationDestination(for: String.self) { text in
                Text(verbatim: text)
            }
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
