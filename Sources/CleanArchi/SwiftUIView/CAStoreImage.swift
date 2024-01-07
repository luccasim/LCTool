//
//  CAStoreImage.swift
//  Mon Compte Free
//
//  Created by Free on 10/08/2023.
//

import SwiftUI

/// This View store an Image on the user device
/// Then load the stored image data when
/// Each time the request change, the view download the image,
/// But replace / publish change only if the new data is different of the oldest stored image.
struct CAStoreImage: View {
    
    @StateObject fileprivate var viewModel: CAStoreImageViewModel
    
    fileprivate var request: URLRequest?
//    fileprivate var placeholder: ImageResource
    
    // MARK: - Init
    
    init(path: String?) {
        self.request = URLRequest(path: path ?? "")
//        self.placeholder = placeholder
        _viewModel = StateObject(wrappedValue: CAStoreImageViewModel(url: path.flatMap({URL(string: $0)})))
    }
    
    init(url: URL?) {
        self.request = URLRequest(path: url?.absoluteString ?? "")
//        self.placeholder = placeholder
        _viewModel = StateObject(wrappedValue: CAStoreImageViewModel(url: url))
    }
    
    init(request: URLRequest?) {
        self.request = request
//        self.placeholder = placeholder
        _viewModel = StateObject(wrappedValue: CAStoreImageViewModel(url: request?.url))
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if let img = viewModel.imageData.flatMap({UIImage(data: $0)}) {
                Image(uiImage: img)
                    .resizable()
            } else {
//                Image(placeholder)
                Rectangle()
            }
        }
        .onChange(of: request) { newValue in
            viewModel.fetch(request: newValue)
        }
        .onAppear {
            viewModel.fetch(request: request)
        }
    }
    
    static func preloadImages(requests: [URLRequest], completion: @escaping (() -> Void)) {
        CADownloadDataManager.shared.load(requests: requests, completion: completion)
    }
    
    static func preloadImages(requests: [URLRequest]) async {
        await withCheckedContinuation { continuation in
            CADownloadDataManager.shared.load(requests: requests) {
                continuation.resume()
            }
        }
    }
}

private final class CAStoreImageViewModel: ObservableObject {
    
    @Published var imageData: Data?
    
    private var manager = CADownloadDataManager.shared
    
    init(url: URL?) {
        imageData = manager.retrieveData(url: url)
    }
    
    func fetch(request: URLRequest?) {
        if let request = request {
            manager.fetchData(request: request) { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        self.imageData = data
                    }
                default:
                    break
                }
            }
        }
    }
}

struct CAStoreImage_Previews: PreviewProvider {
    static var previews: some View {
        CAStoreImage(
            path: "https://media.istockphoto.com/id/92911783/fr/photo/mendicité-beaver.jpg" +
                     "?s=612x612&w=0&k=20&c=iNnVt_Dvms2Y8lSlEtNdz0sr7OKWr02l1656c6KBS2w="
        )
        .scaledToFit()
    }
}
