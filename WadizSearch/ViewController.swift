//
//  ViewController.swift
//  WadizSearch
//

import UIKit
import SwiftUI
import SafariServices
import Combine


class ViewControllerModel : ObservableObject
{
    @Published var data = [Product]()
    @Published var searchText = ""
    @Published var index = 0
    @Published var arr : Array<String> = []
    @Published var image: UIImage = UIImage()
    @Published var isEditing = false
    private var disposables = Set<AnyCancellable>()
    
    init()
    {
        
        handleData(data: "캠핑")
        
        $searchText.dropFirst(1)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
            }, receiveValue: { [weak self] result in
                self?.handleData(data: result)
            })
            .store(in: &disposables)
       
    }
    
 
    
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
    
    func handleData(data: String)
    {
        API.search(keyword: data)
            .get { result in
                 
                
                self.data = try! result.get().body.list
               
               // print(self.data)
                
            }
        
    }
    
    func getImage(data : String) -> Image
    {
        guard let img = UIImage(named: data) else {
            fatalError("Fail to load image")
        }

        return Image(uiImage: img)
    }
    
    func separation(data : String) -> Array<String>
    {
        let item = data.components(separatedBy: ",")
        var special1 : Array<String> = [] // #
        var special2 : Array<String> = [] // @
        var result : Array<String> = []
        
        for value in item
        {
            if value.contains("#")
            {
                special1.append(value)
            }
            else
            {
                special2.append(value)
                
            }
        }
       
        for x in special2
        {
            if result.count < 3
            {
                result.append(x.trimmingCharacters(in: [" "]))
            }
        }
        for x in special1
        {
            if result.count < 3
            {
                result.append(x.trimmingCharacters(in: [" "]))
//                var umm = x.trimmingCharacters(in: [" "])
//                umm.insert(" ", at:  umm.index(umm.startIndex, offsetBy: 0))
//                result.append(umm)
            }
        }
        
      
       return result
       
    }
    func addComma(data : Int) -> String
    {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        let price = data
        let result = numberFormatter.string(from: NSNumber(value:price))!
        return result
    }
}

struct ViewController : View
{
    @ObservedObject var viewModel = ViewControllerModel()
    var body: some View
    {
        NavigationView
        {
            VStack(spacing:0)
            {
                HStack
                {
                    HStack(spacing:10)
                    {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 20, height: 20)
                        TextField("어떤프로젝트를 찾고계신가요", text: $viewModel.searchText)
                    }
                    .frame(maxWidth:.infinity,alignment: .leading)
                    .padding(.vertical,8)
                    .padding(.leading,15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(ThemeColor.MainColor.getSwiftUIColor(),lineWidth: 1.0)
                        
                    )
                    .onTapGesture(perform: {
                        viewModel.isEditing = true
                    })
                    
                    if viewModel.isEditing
                    {
                        Button(action: {
                            self.viewModel.isEditing = false
                            self.viewModel.searchText = ""
                            
                        }) {
                            Text("Cancel")
                        }
                        .padding(.trailing, 10)
                        .transition(.move(edge: .trailing))
                        .animation(.default)
                    }
                        
                   
                }
               
                HStack
                {
                    Button(action: {
                        viewModel.handleData(data: "전체")
                        viewModel.index = 0
                    }, label: {
                        VStack
                        {
                            Text("전체")
                                .foregroundColor(viewModel.index == 0 ? Color.black : Color.gray)
                            Capsule()
                                .fill(viewModel.index == 0 ? Color.black : Color.clear)
                                .frame(height: 3)
                        }
                       
                    })
                       
                  
                    Button(action: {
                        viewModel.index = 1
                        viewModel.handleData(data: "펀딩")
                    }, label: {
                        VStack
                        {
                            Text("펀딩")
                                .foregroundColor(viewModel.index == 1 ? Color.black : Color.gray)
                            Capsule()
                                .fill(viewModel.index == 1 ? Color.black : Color.clear)
                                .frame(height: 3)
                        }
                       
                       
                    })
                      
                  
                    Button(action: {
                        viewModel.index = 2
                        viewModel.handleData(data: "스토어")
                       
                      
                    }, label: {
                        VStack
                        {
                            Text("스토어")
                                .foregroundColor(viewModel.index == 2 ? Color.black : Color.gray)
                            Capsule()
                                .fill(viewModel.index == 2 ? Color.black : Color.clear)
                                .frame(height: 3)
                        }
                      
                    })
                        
                }
                .padding(.vertical,15)

                ScrollView
                {
                    ForEach(viewModel.data){ item in
                        HStack
                        {
                            //image
                            CustomImageView(urlString: item.photoURL ?? "")
                               
                        
                            //content
                            VStack(alignment: .leading)
                            {
                                Text(item.title).lineLimit(2)
                                Text(item.category?.name ?? "")
                                    .foregroundColor(Color.gray)
                                
                                HStack
                                {
                                    ForEach(viewModel.separation(data: item.additionalInfo!) , id:\.self)
                                    { value in
                                        
                                        Button(action: {
//                                            # 이 붙은 키워드를 누르면 해당 키워드로 다시 검색합니다.
//                                            @ 이 붙은 키워드를 누르면 메이커 페이지(makerPage)를 웹뷰로 보여줍니다.
                                            if value.contains("#")
                                            {
                                                viewModel.handleData(data: value)
                                            }
                                            else
                                            {
                                                openSFSafariView(item.makerPage)
                                            }
                                            
                                            
                                            
                                        }, label: {
                                            Text(value)
                                                .foregroundColor(Color.blue)
                                        })
                                        
                                    }
                                }
                               
                               
                                HStack
                                {
                                    Text(viewModel.addComma(data: item.targetAmount ?? 0))
                                        .foregroundColor(ThemeColor.MainColor.getSwiftUIColor())
                                        .fontWeight(.bold)
                                         Text("원")
                                }
                                
                                
                            }
                        }
                        
                        
                    }
                }
               
  
            }
            .navigationBarTitle("", displayMode: .inline)
            .padding(.horizontal,20)
            .padding(.top,20)
            
            
        }
    
        
        
    }
    
    func openSFSafariView(_ targetURL: String) {
        
        
        if let url = URL(string: targetURL) {
            UIApplication.shared.open(url)
        }
        
      
    }
}
