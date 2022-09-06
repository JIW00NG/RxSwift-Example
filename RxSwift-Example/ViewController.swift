//
//  ViewController.swift
//  RxSwift-Example
//
//  Created by JiwKang on 2022/09/06.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var timer: UILabel!
    
    private var observable: Observable = Observable
        .just("https://source.unsplash.com/random")
        .map { URL(string: $0)! }
        .map{ try Data(contentsOf: $0) }
        .map{ UIImage(data: $0) }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
        .observe(on: MainScheduler.instance)
    
    private var timeObservable = Observable<Int>.interval(RxTimeInterval.milliseconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
        .map { "\($0)" }
        .observe(on: MainScheduler.instance)
    
    private var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        imageButton.configuration?.image = UIImage(systemName: "circle")
        imageButton.configuration?.title = ""
        
        imageButton.rx.tap.bind {
            self.downloadImage()
        }.disposed(by: disposeBag)
        
        timeObservable.bind(to: timer.rx.text)
        .disposed(by: disposeBag)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        disposeBag = DisposeBag()
    }
    
    func downloadImage() {
        observable
            .subscribe(onNext: {
                self.imageButton.configuration?.image = $0
            })
            .disposed(by: disposeBag)
    }
}

