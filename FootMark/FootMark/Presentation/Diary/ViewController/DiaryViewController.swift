//
//  DiaryViewController.swift
//  FootMark
//
//  Created by 윤성은 on 3/24/24.
//

import UIKit
import ElegantEmojiPicker
import DropDown
import Foundation

class DiaryViewController: BaseViewController {
    var diaryView = DiaryView()
    let dropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(resource: .black1)
        
        navigationController?.navigationBar.isHidden = true
        
        addEmoji()
        
        setUpDelegates()
        setUpClosures()
        setupDropDown()
    }
    
    override func setLayout() {
        view.addSubviews(diaryView)
        
        diaryView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func setAddTarget() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(emojiLabelTapped))
        diaryView.emojiLabel.addGestureRecognizer(tapGesture)
        
        diaryView.categoryButton.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        
        diaryView.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    func addEmoji() {
        NetworkService.shared.emojiService.postEmoji(request: PostEmojiRequestModel(createAt: "", todayEmoji: "")) { result in
            switch result {
            case .success(let EmojiResponseDTO):
                print(EmojiResponseDTO)
                DispatchQueue.main.async {
                    self.diaryView.emojiLabel.text = EmojiResponseDTO.data.todayEmoji
                }
            case .tokenExpired(_):
                print("만료된 accessToken 입니다. \n재발급을 시도합니다.")
            case .requestErr:
                print("요청 오류입니다")
            case .decodedErr:
                print("디코딩 오류입니다")
            case .pathErr:
                print("경로 오류입니다")
            case .serverErr:
                print("서버 오류입니다")
            case .networkFail:
                print("네트워크 오류입니다")
            }
        }
    }
    
    func editEmoji(createAt: String) {
        NetworkService.shared.emojiService.putEmoji(createAt: createAt, request: PutEmojiRequestModel(todayEmoji: "")) { result in
            switch result {
            case .success(let EmojiResponseDTO):
                print(EmojiResponseDTO)
            case .tokenExpired(_):
                print("만료된 accessToken 입니다. \n재발급을 시도합니다.")
            case .requestErr:
                print("요청 오류입니다")
            case .decodedErr:
                print("디코딩 오류입니다")
            case .pathErr:
                print("경로 오류입니다")
            case .serverErr:
                print("서버 오류입니다")
            case .networkFail:
                print("네트워크 오류입니다")
            }
        }
    }
    
    func setUpDelegates() {
        diaryView.todoTextView.delegate = self
        diaryView.thankfulTextView.delegate = self
        diaryView.bestTextView.delegate = self
    }
    
    func setUpClosures() {
        diaryView.emojiPickerHandler = { [weak self] in
            self?.PresentEmojiPicker()
        }
        
        let actionClosure: (UIAction) -> Void = { [weak self] action in
            self?.diaryView.categoryLabel.text = action.title
        }
    }
    
    @objc func categoryButtonTapped() {
        dropDown.show()
    }
    
    func setupDropDown() {
        dropDown.anchorView = diaryView.categoryButton
        dropDown.bottomOffset = CGPoint(x: 0, y: diaryView.categoryButton.bounds.height + 80)
        dropDown.dataSource = ["운동", "약속", "공부"]
        dropDown.backgroundColor = .white
        
        dropDown.textFont = UIFont.pretendard(size: 18, weight: .regular)
        
        if let firstCategory = dropDown.dataSource.first {
            diaryView.categoryButton.setTitle(firstCategory, for: .normal)
            diaryView.categoryLabel.text = firstCategory
        }
        
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            self?.diaryView.categoryButton.setTitle(item, for: .normal)
            self?.diaryView.categoryLabel.text = item
        }
    }
    
    @objc func saveButtonTapped() {
        print("save")
    }
}

extension DiaryViewController: ElegantEmojiPickerDelegate {
    func PresentEmojiPicker() {
        let picker = ElegantEmojiPicker(delegate: self)
        self.present(picker, animated: true)
    }
    
    func emojiPicker(_ picker: ElegantEmojiPicker, didSelectEmoji emoji: Emoji?) {
        guard let emoji = emoji else { return }
        diaryView.emojiLabel.text = emoji.emoji
    }
    
    @objc func emojiLabelTapped() {
        diaryView.emojiPickerHandler?()
    }
}

extension DiaryViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("텍스트 필드 편집 시작")
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("텍스트 필드 편집 종료")
    }
}
