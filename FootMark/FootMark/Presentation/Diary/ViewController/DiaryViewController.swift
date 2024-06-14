//
//  DiaryViewController.swift
//  FootMark
//
//  Created by 윤성은 on 3/24/24.
//

import UIKit
import ElegantEmojiPicker
import DropDown

class DiaryViewController: BaseViewController {
    var diaryView = DiaryView()
    let dropDown = DropDown()
    
    var categoryTodos: [String: String] = ["운동": "운동 더미 데이터", "공부": "공부 더미 데이터"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(resource: .black1)
        
        navigationController?.navigationBar.isHidden = true
        
        setUpDelegates()
        setUpClosures()
        setupDropDown()
        
        getTodos(createAt: diaryView.dateLabel.text ?? "2023-04-23")
        diaryView.todoLabel.text = categoryTodos["운동"]
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
        NetworkService.shared.emojiService.postEmoji(request: PostEmojiRequestModel(createAt: diaryView.dateLabel.text ?? "", todayEmoji: diaryView.emojiLabel.text ?? "")) { result in
            switch result {
            case .success(let EmojiResponseDTO):
                print(EmojiResponseDTO)
                DispatchQueue.main.async {
                    self.diaryView.dateLabel.text = EmojiResponseDTO.data.createAt
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
        NetworkService.shared.emojiService.putEmoji(createAt: createAt, request: PutEmojiRequestModel(todayEmoji: diaryView.emojiLabel.text ?? "")) { result in
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
    
    func addReview() {
        NetworkService.shared.reviewService.postReview(request: PostReviewRequestModel(createAt: diaryView.dateLabel.text ?? "2024-04-11", categoryId: 0, content: "")) { result in
            switch result {
            case .success(let ReviewResponseDTO):
                print(ReviewResponseDTO)
                DispatchQueue.main.async {
                    self.diaryView.todoTextView.text = ReviewResponseDTO.data.content
                    self.diaryView.thankfulLabel.text = ReviewResponseDTO.data.content
                    self.diaryView.bestTextView.text = ReviewResponseDTO.data.content
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
    
    func editReview(content: String) {
        NetworkService.shared.reviewService.putReview(content: content, request: PutReviewRequestModel(content: "")) { result in
            switch result {
            case .success(let ReviewResponseDTO):
                print(ReviewResponseDTO)
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
    
    func getTodos(createAt: String) {
        print("getTodos 호출됨, createAt: \(createAt)")
        NetworkService.shared.categoryService.getTodos(createAt: diaryView.dateLabel.text ?? "") { result in
            switch result {
            case .success(let TodosResponseDTO):
                print(TodosResponseDTO)
                DispatchQueue.main.async {
                    if let firstCategory = TodosResponseDTO.data.todoDateResDtos.first {
                        self.diaryView.todoLabel.text = firstCategory.content.joined(separator: ", ")
                        self.dropDown.dataSource = TodosResponseDTO.data.todoDateResDtos.map { $0.categoryName }
                        // 카테고리별로 내용을 저장
                        self.categoryTodos = Dictionary(uniqueKeysWithValues: TodosResponseDTO.data.todoDateResDtos.map { ($0.categoryName, $0.content.joined(separator: ", ")) })
                    }
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
        dropDown.dataSource = ["운동", "공부"]
        dropDown.backgroundColor = .white
        
        dropDown.textFont = UIFont.pretendard(size: 18, weight: .regular)
        
        if let firstCategory = dropDown.dataSource.first {
            diaryView.categoryButton.setTitle(firstCategory, for: .normal)
            diaryView.categoryLabel.text = firstCategory
            diaryView.todoLabel.text = categoryTodos[firstCategory] ?? ""
        }
        
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            self?.diaryView.categoryButton.setTitle(item, for: .normal)
            self?.diaryView.categoryLabel.text = item
            self?.diaryView.todoLabel.text = self?.categoryTodos[item] ?? ""
        }
    }
    
    @objc func saveButtonTapped() {
        print("save")
        addEmoji()
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
        if let createAt = diaryView.dateLabel.text {
            editEmoji(createAt: createAt)
        }
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
        addReview()
    }
}
