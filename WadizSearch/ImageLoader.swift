//
//  ImageLoader.swift
//  WadizSearch
//

import UIKit
import Combine
import SwiftUI

enum ImageLoaderError: Error {
    case unknown
    case invalidURL
}

/// 이미지 URL을 받아 이미지를 불러옵니다.
struct ImageLoader {
    let url: String

    func load(completion: @escaping (Result<UIImage, ImageLoaderError>) -> Void) {
        if let url = URL(string: self.url) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard (response as? HTTPURLResponse)?.statusCode == 200,
                      error == nil,
                      let data = data,
                      let image = UIImage(data: data) else {
                    completion(.failure(.unknown))
                    return
                }

                completion(.success(image))
            }.resume()
        } else {
            completion(.failure(.invalidURL))
        }
    }
}





struct CustomImageView: View {
    var urlString: String
    @ObservedObject var imageLoader = ImageLoaderService()
  
 
    @State var image: UIImage = UIImage()
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .frame(width: 150, height: 100)
            
            
            .onReceive(imageLoader.$image) { image in
                self.image = image
            }
            .onAppear {
                imageLoader.loadImage(for: urlString)
            }
    }
}

class ImageLoaderService: ObservableObject {
    @Published var image: UIImage = UIImage()
    
    func loadImage(for urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.image = UIImage(data: data) ?? UIImage()
            }
        }
        task.resume()
    }
    
}

