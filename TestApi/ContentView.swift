import SwiftUI
import Alamofire
import SwiftyJSON

struct ContentView: View {
    @State private var name = ""
    @State private var address = ""
    @State private var imageUrl = ""
    @State private var isShowingShop = false

    var body: some View {
        VStack {
            Button(action: {
                isShowingShop = true
                fetchRamenShop()
            }, label: {
                Text("Fetch Ramen Shop")
            })
            .padding()

            if isShowingShop {
                Text("Ramen Shop")
                    .font(.title)
                    .padding()

                if let url = URL(string: imageUrl), let imageData = try? Data(contentsOf: url) {
                    Image(uiImage: UIImage(data: imageData)!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .padding()
                }

                Text(name)
                    .font(.headline)

                Text(address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }

    func fetchRamenShop() {
        let apiKey = "your API key" // HotPepper APIのAPIキーを設定してください
        let baseUrl = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/"

        let apiKeyEncoded = apiKey.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let keywordEncoded = "ラーメン".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        let urlString = "\(baseUrl)?key=\(apiKeyEncoded)&large_area=Z011&format=json&count=1&keyword=\(keywordEncoded)"

        if let url = URL(string: urlString) {
            AF.request(url)
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        print(json)
                        let shopData = json["results"]["shop"].arrayValue.first
                        if let shopData = shopData {
                            name = shopData["name"].stringValue
                            address = shopData["address"].stringValue
                            imageUrl = shopData["photo"]["pc"]["l"].stringValue
                        }
                    case .failure(let error):
                        print("API Request Error: \(error)")
                    }
                }
        } else {
            print("Invalid URL: \(urlString)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
