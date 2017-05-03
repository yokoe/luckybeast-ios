import UIKit
import AVFoundation

protocol CapturerDelegate: class {
    func capturer(_ capturer: Capturer, didCaptureImage image: UIImage)
}

class Capturer: NSObject {
    fileprivate var captureSession: AVCaptureSession!
    fileprivate var stillImageOutput: AVCapturePhotoOutput?
    
    weak var delegate: CapturerDelegate?
    
    func start() {
        captureSession = AVCaptureSession()
        stillImageOutput = AVCapturePhotoOutput()
        
        captureSession.sessionPreset = AVCaptureSessionPreset640x480
        guard let device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front) else {
            fatalError("no front camera")
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)

                if (captureSession.canAddOutput(stillImageOutput)) {
                    captureSession.addOutput(stillImageOutput)
                    captureSession.startRunning()
                }
            }
        } catch {
            debugPrint(error)
        }
    }
    
    func capture() {
        let settings = AVCapturePhotoSettings()
        settings.isAutoStillImageStabilizationEnabled = true
        settings.isHighResolutionPhotoEnabled = false
        stillImageOutput?.capturePhoto(with: settings, delegate: self)
    }
}

extension Capturer: AVCapturePhotoCaptureDelegate {
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        guard let photoSampleBuffer = photoSampleBuffer,
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer),
            let image = UIImage(data: photoData) else {
                fatalError("Capture failure.")
        }
        
        delegate?.capturer(self, didCaptureImage: image)
    }
}
