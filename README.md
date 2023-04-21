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
<img src="https://user-images.githubusercontent.com/114917347/232789578-e25b9616-6bd5-4eb9-8883-c94f0fa34f11.png" width="750">

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

Financial Modeling PrepのStarerプラン以上のキーを取得して、`APIKeyProtocol`に適合した`APIKey`クラスを本体のモジュール内に定義します。

`APIKey`クラスが見つからない場合は、モックを返すMockAPIServiceとインメモリのInMemoryPortfolioServiceがセットされ、ビルドができます。

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
