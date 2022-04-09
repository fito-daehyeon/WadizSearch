//
//  SearchNavigation.swift
//  WadizSearch
//
//  Created by DaeHyeon Kim on 2022/04/09.
//

import Foundation
import UIKit
import SwiftUI

struct SearchNavigation<Content: View>: UIViewControllerRepresentable {
    @Binding var text: String
  
    var search: () -> Void
    var cancel: () -> Void
    var searchbegin: () -> Void
    var content: () -> Content

    func makeUIViewController(context: Context) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: context.coordinator.rootViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        
        context.coordinator.searchController.searchBar.delegate = context.coordinator
        
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        context.coordinator.update(content: content())
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(content: content(), searchText: $text, searchAction: search, cancelAction: cancel,searchbegin:searchbegin)
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        let rootViewController: UIHostingController<Content>
        let searchController = UISearchController(searchResultsController: nil)
        var search: () -> Void
        var cancel: () -> Void
        var searchbegin: () -> Void
        
        init(content: Content, searchText: Binding<String>, searchAction: @escaping () -> Void, cancelAction: @escaping () -> Void,searchbegin: @escaping () -> Void) {
            rootViewController = UIHostingController(rootView: content)
            searchController.searchBar.autocapitalizationType = .none
            searchController.searchBar.placeholder = "어떤 프로젝트를 찾고 계신가요"
            searchController.searchBar.setValue("취소", forKey: "cancelButtonText")
            searchController.obscuresBackgroundDuringPresentation = false
            
            
            rootViewController.navigationItem.searchController = searchController
           
            rootViewController.navigationItem.hidesSearchBarWhenScrolling = false
            
            _text = searchText
            search = searchAction
            cancel = cancelAction
            self.searchbegin = searchbegin
           
        }
        
        func update(content: Content) {
            rootViewController.rootView = content
            rootViewController.view.setNeedsDisplay()
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
        {
            searchbegin()
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            search()
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            cancel()
        }
    }
    
}
