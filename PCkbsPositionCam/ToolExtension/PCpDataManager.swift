//
//  PCpDataManager.swift
//  PCkbsPositionCam
//
//  Created by JOJO on 2022/2/9.
//

import Foundation
import BBMetalImage
import UIKit

struct PCpLayoutItem: Codable {
    var layout: String
    var thumb: String
}

class PCpDataManager {
    static let `default` = PCpDataManager()
    var filterList: [CamFilterItem] = []
    var layoutTypeList: [PCpLayoutItem] {
        return PCpDataManager.default.loadJson([PCpLayoutItem].self, name: "layout") ?? []
    }
    init() {
        loadFilter()
    }
    
    func loadFilter() {
        
        let beauty = CamFilterItem(filterType: .beauty)
        let rgba1 = CamFilterItem(filterType: .rgba1)
        let rgba2 = CamFilterItem(filterType: .rgba2)
        let rgba3 = CamFilterItem(filterType: .rgba3)
        let rgba4 = CamFilterItem(filterType: .rgba4)
        let rgba5 = CamFilterItem(filterType: .rgba5)
        let hue1 = CamFilterItem(filterType: .hue1)
        let hue2 = CamFilterItem(filterType: .hue2)
        let hue3 = CamFilterItem(filterType: .hue3)
        let hue4 = CamFilterItem(filterType: .hue4)
        let vibrance = CamFilterItem(filterType: .vibrance)
        let highlightShadowTint = CamFilterItem(filterType: .highlightShadowTint)
        let lookup1 = CamFilterItem(filterType: .lookup1)
        let lookup2 = CamFilterItem(filterType: .lookup2)
        let lookup3 = CamFilterItem(filterType: .lookup3)
        let lookup4 = CamFilterItem(filterType: .lookup4)
        let lookup5 = CamFilterItem(filterType: .lookup5)
        let lookup6 = CamFilterItem(filterType: .lookup6)
        let lookup7 = CamFilterItem(filterType: .lookup7)
        let lookup8 = CamFilterItem(filterType: .lookup8)
        let lookup9 = CamFilterItem(filterType: .lookup9)
        let lookup10 = CamFilterItem(filterType: .lookup10)
        let monochrome1 = CamFilterItem(filterType: .monochrome1)
        let monochrome2 = CamFilterItem(filterType: .monochrome2)
        let monochrome3 = CamFilterItem(filterType: .monochrome3)
        let monochrome4 = CamFilterItem(filterType: .monochrome4)
        let monochrome5 = CamFilterItem(filterType: .monochrome5)
        let zoomBlur = CamFilterItem(filterType: .zoomBlur)
        let tiltShift = CamFilterItem(filterType: .tiltShift)
        let pixellate = CamFilterItem(filterType: .pixellate)
        let polkaDot = CamFilterItem(filterType: .polkaDot)
        let halftone = CamFilterItem(filterType: .halftone)
        let crosshatch = CamFilterItem(filterType: .crosshatch)
        let sketch = CamFilterItem(filterType: .sketch)
        let vignette = CamFilterItem(filterType: .vignette)
        let kuwahara = CamFilterItem(filterType: .kuwahara)
        let swirl = CamFilterItem(filterType: .swirl)
        let bulge = CamFilterItem(filterType: .bulge)
        let pinch = CamFilterItem(filterType: .pinch)
        let sobelEdgeDetection = CamFilterItem(filterType: .sobelEdgeDetection)
          
        
        //
        filterList = [beauty,
                         zoomBlur,
                         tiltShift,
                         pixellate,
                         polkaDot,
                         halftone,
                         crosshatch,
                         sketch,
                         vignette,
                         kuwahara,
                         sobelEdgeDetection,
                         swirl,
                         bulge,
                         pinch,
                         rgba1,
                         rgba2,
                         rgba3,
                         rgba4,
                         rgba5,
                         hue1,
                         hue2,
                         hue3,
                         hue4,
                         vibrance,
                         highlightShadowTint,
                         lookup1,
                         lookup2,
                         lookup3,
                         lookup4,
                         lookup5,
                         lookup6,
                         lookup7,
                         lookup8,
                         lookup9,
                         lookup10,
                         monochrome1,
                         monochrome2,
                         monochrome3,
                         monochrome4,
                         monochrome5]
    }
}


extension PCpDataManager {
    func loadJson<T: Codable>(_: T.Type, name: String, type: String = "json") -> T? {
        if let path = Bundle.main.path(forResource: name, ofType: type) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                return try! JSONDecoder().decode(T.self, from: data)
            } catch let error as NSError {
                debugPrint(error)
            }
        }
        return nil
    }
    
    func loadJson<T: Codable>(_:T.Type, path:String) -> T? {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            do {
                return try PropertyListDecoder().decode(T.self, from: data)
            } catch let error as NSError {
                print(error)
            }
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    func loadPlist<T: Codable>(_:T.Type, name:String, type:String = "plist") -> T? {
        if let path = Bundle.main.path(forResource: name, ofType: type) {
            return loadJson(T.self, path: path)
        }
        return nil
    }
    
}

class CamFilterItem: NSObject {
    var filterType: FilterType
    var thumbImgStr: String
    var filter: BBMetalBaseFilter?
    
    
    init(filterType: FilterType) {
        self.filterType = filterType
        self.thumbImgStr = filterType.rawValue
        super.init()
        self.filter = makeFilter()
    }
    
    func processImg(img: UIImage) -> UIImage {
        let filter = makeFilter()
        let filtedImg = filter.filteredImage(with: img)
        return filtedImg ?? img
    }
    
    func makeFilter() -> BBMetalBaseFilter {
        switch filterType {
        case .beauty:
            return BBMetalBeautyFilter()
        case .rgba1:
            return BBMetalRGBAFilter(red: 1.2, green: 1, blue: 1, alpha: 1)
        case .rgba2:
            return BBMetalRGBAFilter(red: 1, green: 1.2, blue: 1, alpha: 1)
        case .rgba3:
            return BBMetalRGBAFilter(red: 1, green: 1, blue: 1.2, alpha: 1)
        case .rgba4:
            return BBMetalRGBAFilter(red: 1.2, green: 1.2, blue: 1, alpha: 1)
        case .rgba5:
            return BBMetalRGBAFilter(red: 1.2, green: 1.2, blue: 1.2, alpha: 1)
        case .hue1:
            return BBMetalHueFilter(hue: 40)
        case .hue2:
            return BBMetalHueFilter(hue: 80)
        case .hue3:
            return BBMetalHueFilter(hue: 120)
        case .hue4:
            return BBMetalHueFilter(hue: 180)
        case .vibrance:
            return BBMetalVibranceFilter(vibrance: 1)
        case .highlightShadowTint:
            return BBMetalHighlightShadowTintFilter(shadowTintColor: .blue,
                                                         shadowTintIntensity: 0.5,
                                                         highlightTintColor: .red,
                                                         highlightTintIntensity: 0.5)
        case .lookup1:
            let lookupF = try! BBMetalLookupFilter(lookupTable: Data(contentsOf: Bundle.main.url(forResource: "lookup1", withExtension: "png")!).bb_metalTexture!, intensity: 1)
            return lookupF
        case .lookup2:
            let lookupF = try! BBMetalLookupFilter(lookupTable: Data(contentsOf: Bundle.main.url(forResource: "lut_mangu", withExtension: "png")!).bb_metalTexture!, intensity: 1)
            return lookupF
        case .lookup3:
            let lookupF = try! BBMetalLookupFilter(lookupTable: Data(contentsOf: Bundle.main.url(forResource: "lut_mianhuatang", withExtension: "png")!).bb_metalTexture!, intensity: 1)
            return lookupF
        case .lookup4:
            let lookupF = try! BBMetalLookupFilter(lookupTable: Data(contentsOf: Bundle.main.url(forResource: "lut_riguang", withExtension: "png")!).bb_metalTexture!, intensity: 1)
            return lookupF
        case .lookup5:
            let lookupF = try! BBMetalLookupFilter(lookupTable: Data(contentsOf: Bundle.main.url(forResource: "lut_tengman", withExtension: "png")!).bb_metalTexture!, intensity: 1)
            return lookupF
        case .lookup6:
            let lookupF = try! BBMetalLookupFilter(lookupTable: Data(contentsOf: Bundle.main.url(forResource: "lookup_002", withExtension: "png")!).bb_metalTexture!, intensity: 1)
            return lookupF
        case .lookup7:
            let lookupF = try! BBMetalLookupFilter(lookupTable: Data(contentsOf: Bundle.main.url(forResource: "lut3", withExtension: "png")!).bb_metalTexture!, intensity: 1)
            return lookupF
        case .lookup8:
            let lookupF = try! BBMetalLookupFilter(lookupTable: Data(contentsOf: Bundle.main.url(forResource: "lut7", withExtension: "png")!).bb_metalTexture!, intensity: 1)
            return lookupF
        case .lookup9:
            let lookupF = try! BBMetalLookupFilter(lookupTable: Data(contentsOf: Bundle.main.url(forResource: "lut10", withExtension: "png")!).bb_metalTexture!, intensity: 1)
            return lookupF
        case .lookup10:
            let lookupF = try! BBMetalLookupFilter(lookupTable: Data(contentsOf: Bundle.main.url(forResource: "lut15", withExtension: "png")!).bb_metalTexture!, intensity: 1)
            return lookupF
        case .monochrome1:
            return BBMetalMonochromeFilter(color: BBMetalColor(red: 0.7, green: 0.6, blue: 0.5), intensity: 1)
        case .monochrome2:
            return BBMetalMonochromeFilter(color: BBMetalColor(red: 0.3, green: 0.6, blue: 0.4), intensity: 1)
        case .monochrome3:
            return BBMetalMonochromeFilter(color: BBMetalColor(red: 0.3, green: 0.5, blue: 0.7), intensity: 1)
        case .monochrome4:
            return BBMetalMonochromeFilter(color: BBMetalColor(red: 0.8, green: 0.5, blue: 0.7), intensity: 1)
        case .monochrome5:
            return BBMetalMonochromeFilter(color: BBMetalColor(red: 0.3, green: 0.9, blue: 0.4), intensity: 1)
        case .zoomBlur:
            return BBMetalZoomBlurFilter(blurSize: 3, blurCenter: BBMetalPosition(x: 0.5, y: 0.5))
        case .tiltShift:
            return BBMetalTiltShiftFilter(sigma: 30, topFocusLevel: 14.6, bottomFocusLevel: 55.8, focusFallOffRate: 25.5)
        case .pixellate:
            return BBMetalPixellateFilter(fractionalWidth: 0.02)
        case .polkaDot:
            return BBMetalPolkaDotFilter(fractionalWidth: 0.02, dotScaling: 0.9)
        case .halftone:
            return BBMetalHalftoneFilter(fractionalWidth: 0.01)
        case .crosshatch:
            return BBMetalCrosshatchFilter(crosshatchSpacing: 0.005, lineWidth: 0.003)
        case .sketch:
            return BBMetalSketchFilter(edgeStrength: 0.85)
        case .vignette:
            return BBMetalVignetteFilter(center: .center, color: .black, start: 0.1, end: 0.5)
        case .kuwahara:
            return BBMetalKuwaharaFilter(radius: 4)
        case .swirl:
            return BBMetalSwirlFilter(center: BBMetalPosition(x: 0.5, y: 0.5), radius: 0.25, angle: 0.12)
        case .bulge:
            return BBMetalBulgeFilter(center: BBMetalPosition(x: 0.5, y: 0.5), radius: 0.5, scale: 0.5)
        case .pinch:
            return BBMetalPinchFilter(center: BBMetalPosition(x: 0.5, y: 0.5), radius: 0.5, scale: 0.5)
        case .sobelEdgeDetection:
            return BBMetalSobelEdgeDetectionFilter()
        }
    }
    
    
}

enum FilterType: String {
    case beauty
    case rgba1
    case rgba2
    case rgba3
    case rgba4
    case rgba5
    case hue1
    case hue2
    case hue3
    case hue4
    case vibrance
    case highlightShadowTint
    case lookup1
    case lookup2
    case lookup3
    case lookup4
    case lookup5
    case lookup6
    case lookup7
    case lookup8
    case lookup9
    case lookup10
    case monochrome1
    case monochrome2
    case monochrome3
    case monochrome4
    case monochrome5
    case zoomBlur
    case tiltShift
    case pixellate
    case polkaDot
    case halftone
    case crosshatch
    case sketch
    case vignette
    case kuwahara
    case swirl
    case bulge
    case pinch
    case sobelEdgeDetection
}


