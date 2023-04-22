# Fintone

Fintone is a stock portfolio app for US stocks and ETFs.  
You can view your portfolio's performance graphically with a chart.  
With iCloud sync enabled, data is synced between devices that are signed in with the same AppleID.  

Fintoneは、米国株式・ETFに対応したポートフォリオ管理アプリです。  
あなたのポートフォリオのパフォーマンスを視覚的に確認できます。  
iCloud同期が有効な場合、同一AppleIDでログインされたデバイス間でデータが同期されます。

Data provided by [Financial Modeling Prep](https://financialmodelingprep.com/developer/docs/)

<a href="https://apps.apple.com/us/app/smartpf/id1635493374?itsct=apps_box_badge&amp;itscg=30200">
  <img src="https://user-images.githubusercontent.com/114917347/201505856-01f766e0-aedd-409d-89d6-29cef70a32ae.svg" 
       alt="Download on the App Store"
       style="height: 50px;">
</a>

## Screenshot
|<img src="https://user-images.githubusercontent.com/114917347/233761121-d426c397-2754-4bc3-a0de-469920b48282.png" width="250">|<img src="https://user-images.githubusercontent.com/114917347/233761125-68388f04-091d-4e8d-a9e9-867c2584029e.png" width="250">|<img src="https://user-images.githubusercontent.com/114917347/233761130-17c9e6e3-4e8c-4a25-ab66-bc109bebfa89.png" width="250">|
|:-:|:-:|:-:|

## Stack
Swift5.7+, iOS15+, UIKit, Swift Concurrency, XCTest, R.swift, SwiftFormat, [SemiCircleChart](https://github.com/skw398/SemiCircleChart)

## Architecture
- `PortfolioServiceProtocol` ポートフォリオデータの管理。実体はPortfolioService（iCloud）とInMemoryPortfolioService（インメモリ）。
- `APIServiceProtocol` 株式データの取得。実体はAPIService（Financial Modeling Prep）とMockAPIService（モック）。UseCaseから利用。
- `ServiceDependencies` PortfolioServiceProtocol、APIServiceProtocolの実体をセット。
- `FetchStocksAndFinancialDataUseCase` `StockSearchUseCase` APIServiceProtocolを注入。テスト可能。
- `PortfolioViewDataModel` PortfolioServiceProtocolを注入。PortfolioViewControllerに表示するデータの管理。テスト可能。
- `PortfolioViewPresenter` UseCase、DataModelを叩いてPortfolioViewControllerに画面更新、遷移のアウトプット。
- その他のViewControllers。

## To Run

Open `App/Develop.xcodeproj` -> Select target `Develop` -> `⌘R` !!

- Swift Package Managerを使っています。手動でのライブラリのダウンロードは必要ありません。
- `R.swift`の生成ファイルは`App/Resouces`に含まれています。プラグインの設定は必要ありません。
- `Develop.xcodeproj`は`APIKey`クラスを定義した`APIKey.swift`への参照がないため、モックを返すMockAPIServiceとインメモリのInMemoryPortfolioServiceがセットされます。
- `APIKeyProtocol`に適合した`APIKey`クラスを本体のモジュール内に定義した場合、本番用のAPIServiceとPortfolioServiceがセットされます。なおFinancial Modeling PrepのStarerプラン以上のAPIキーが必要です。

<details>
  <summary>使えるモックSymbols</summary>
  
```swift
    static let availableSymbols = [
        "AAPL": "アップル",
        "AMZN": "アマゾン",
        "GOOG": "グーグル",
        "MSFT": "マイクロソフト",
        "META": "メタ",
        "WMT": "ウォルマート",
        "TSLA": "テスラ",
        "KO": "コカコーラ",
        "SBUX": "スターバックス",
        "COST": "コストコ",
        "PYPL": "ペイパル",
        "NIKE": "ナイキ",
        "NVDA": "エヌヴィディア",
        "ADBE": "アドビ",
        "INTC": "インテル",
        "DIS": "ディズニー",
        "MCD": "マクドナルド",
        "CSCO": "シスコシステムズ",
        "AXP": "アメリカンエキスプレス",
        "PEP": "ペプシコ",
        "BA": "ボーイング",
        "GS": "ゴールドマンサックス",
        "JNJ": "ジョンソンエンドジョンソン",
        "GM": "ゼネラルモーターズ",
        "HPE": "ヒューレットパッカード",
        "NFLX": "ネットフリックス",
        "MA": "マスターカード",
        "V": "ビザ",
        "JPM": "ジェイピーモルガン",
        "BRK-A": "バークシャーA株",
        "BRK-B": "バークシャーB株",
    ]

    static let availableETFs = ["SPY", "QQQ", "VTI", "ARKK", "ARKG", "VOO", "VWO", "IWM", "EEM", "VNQ"]
```
</details>

<details>
  <summary>APIKeyクラスの定義</summary>
  
```swift
/*
protocol APIKeyProtocol: AnyObject {
    static var key: String { get }
}
*/

final class APIKey: APIKeyProtocol {
    static var key: String { "Your Key" }
}
```
</details>
