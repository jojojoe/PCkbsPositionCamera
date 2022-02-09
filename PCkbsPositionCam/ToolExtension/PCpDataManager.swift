//
//  PCpDataManager.swift
//  PCkbsPositionCam
//
//  Created by JOJO on 2022/2/9.
//

import Foundation
import BBMetalImage
import UIKit


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


