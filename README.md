# Twitter-Clone

Github: https://github.com/choijaegwon/Twitter-Clone  
Skills: ActiveLabel, CocoaPods, Firebase, MVVM, SDWebImage  
생성일: 2022/10/17

## 개요.

- Firebase사용법과 Delegate패턴, MVVM패턴, 코드로 UI구현을 학습하기 위한 기능학습 프로젝트 입니다.

## 구현기능.

- 트윗 게시하기
- 댓글
- 맨션
- 맨션 알람 기능
- 좋아요
- 해시태그
- 알람 받기
- 프로필 편집하기

## 배운점.

### 로그인이 되어있을때, 안되어있을때 구분해서 메모리관리해주는 방법

- MainTabController을 rootView로 깔아두고, Firebase에서 로그인이 안되어있으면, LoginController를 위에 스택에 놓아줘서 메모리관리하는 방법을 배웠습니다.
- 코드보기
    
    ```swift
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
         // 시작화면 설정     
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        window?.rootViewController = MainTabController()
    		window?.makeKeyAndVisible()
    }
    ```
    
    시작화면을 메인화면으로 설정한 후
    
    ```swift
    // 로그인 되어있을때, 안되어있을때 화면 구분하기
    func authenticateUserAndConfigureUI() {
        // 로그인이 안되어있으면, 로그인화면 보여주기
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            // 각종 설정들
        }
    }
    ```
    
    인증 유무로 View를 바꿔주면됩니다.
    

### Extensions, Utilities, Constants등을 활용한 구현

- 자주 사용하는 코드를 Utils 폴더를 만든후  Extensions, Utilities, Constants파일들을 만들어 사용하는 기술을 배웠습니다.

### UITapGestureRecognizer를 활용한 구현

- UITapGestureRecognizer를 활용해서, image와 button클릭시 함수를 실행할 수 있게 되었습니다.

### 스토리보드를 사용하지 않고 코드로 UI 구현

- 코드로 UI를 구현하니 View의 재사용성이 높아지고, 
스토리보드에 없는 옵션들을 따로 적지 않고 하나로 묶어줄 수 있어서 더욱 좋았던 것 같습니다.
또 extension을 사용해서, 쉽게 anchor잡고 활용하는 방법을 배웠습니다.

### ****SDWebImage 라이브러리****

- URL방식으로 이미지 받아오는 것을 비동기적으로 처리하고, 받아온 이미지를 캐싱하여 사용할 수 있게 해주는 라이브러리를 활용하여, URL방식으로 이미지를 받아오는 속도를 개선하는방법을 배웠습니다.

### MVVM디자인 패턴

- 이전 프로젝트를 통해, MVC패턴을 먼저 파악하였고, 이번 프로젝트를 통해 MVVM패턴을 배웠습니다.
비록 MVVC의 View와 Model이 서로 독립성을 유지하여 생기는 가장 큰 장점인 
테스트의 용이성을 사용하진 못했지만, 
View로 틀을 잡아주고, ViewModel로 안에 데이터를 넣어주니 좀 더 코드를 분리할 수 있어서 View의 코드의 양이 줄어서 보기 더 좋았습니다.

### Delegate패턴

- 직접 구현해서 사용하였고, 언제 왜 필요한지 이해하였습니다.

### Firebase활용

- FirebaseAuth를 활용한 로그인
    
![Untitled](https://github.com/choijaegwon/choijaegwon.github.io/assets/68246962/b9d268ef-2b6e-4e22-952e-bff9bb83c367)  
    
- Realtime Database를 활용한 실시간 데이터 통신
    
![Untitled 1](https://github.com/choijaegwon/choijaegwon.github.io/assets/68246962/52797294-3b6b-4f3c-80a2-27d7003ff868)  
    
- Storagr를 활용한 사진 데이터 저장
    
![Untitled 2](https://github.com/choijaegwon/choijaegwon.github.io/assets/68246962/00f5a43e-b054-4eec-9017-f50411fc3d88)  
    

## 직접 구현한 기능

### 알람을 시간 순서대로 가져오는 기능

- 구현방법: sorted 메서드 활용

원래코드

```swift
func fetchNotifications() {
    // 가져온후 새로고침 끝내기
    refreshControl?.endRefreshing()
        
    NotificationService.shared.fetchNotification { notifications in
       // 가져온후 새로고침 끝내기
        self.refreshControl?.endRefreshing()
        self.notifications = notifications
        self.checkIfUserIsFollowed(notifications: notifications) 
    }
}
```

바꾼 코드

```swift
func fetchNotifications() {
    // 가져온후 새로고침 끝내기
    refreshControl?.endRefreshing()
        
    NotificationService.shared.fetchNotification { notifications in
        // 알람 순서 정렬하기
        self.notifications = notifications.sorted(by: { $0.timestamp > $1.timestamp })
        self.checkIfUserIsFollowed(notifications: notifications)
        self.refreshControl?.endRefreshing()
    }
}
```

### 트윗을 볼때 작성자의 프로필을 누르면 작성자로 이동

- 구현방법: Delegate패턴 활용

TweetHeader.swift

```swift
// TweetHeaderDelegate에
func showProfileUser() 
// 작성 후 
@objc func handleProfileImageTapped() {
    delegate?.showProfileUser()
}
```

TweetController.swift

```swift
func showProfileUser() {
    let controller = ProfileController(user: tweet.user)
    navigationController?.pushViewController(controller, animated: true)
}
```

### 맨션 클릭시 프로필로 이동하게 되는데, 더미데이터만 만들고 직접구현을 안했었는데,
회원가입시 데이터가 추가되게 구현

AuthServie.swift

```swift
Database.database().reference().child("user-username").updateChildValues([username: uid])
```

## 오류 해결방안

### windows' was deprecated in iOS 15.0: Use UIWindowScene.windows on a relevant window scene instead

- 해결방법: ios가 업데이트 되면서 사용하는 코드를 바꿔줘야했다.

원래 코드

```swift
guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
```

바뀐 코드

```swift
let scenes = UIApplication.shared.connectedScenes
let windowScene = scenes.first as? UIWindowScene
guard let window = windowScene?.windows.first(where: { $0.isKeyWindow }) else { return }
```

### 자기소개(bio)가 표시되지 않았던 문제

- 해결방법: viewModel를 활용해서 데이터넣는 코드를 빼먹었어서 직접 구현해서 넣어줬다.

```swift
// ProfileHeaderViewModel.swift 에서
var bioString: String? {
	return user.bio
}
속성을 추가해준후,

// ProfileHeader.swift 에서
fun configure() 메서드안에 
bioLabel.text = viewModel.bioString를 추가해주었다.
```

### Feed에서 하트를 누르고 들어가보면 적용이 안됬던 문제

- 해결방법: 뷰의 생명주기 view will appear메서드를 활용해서 해결

```swift
// TweetController.swift에 추가
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    TweetService.shared.checkIfUserLikedTweet(tweet) { didLike in
        self.tweet.didLike = didLike
    }
}
```

전

![Oct-26-2022_21-33-03](https://github.com/choijaegwon/choijaegwon.github.io/assets/68246962/9d40747a-4172-4322-926a-c44a20c68526)  

후

![Oct-26-2022_21-34-10](https://github.com/choijaegwon/choijaegwon.github.io/assets/68246962/2e6ae2a7-d4e4-4249-8a9d-85bfaa888275)  

### Cell의 이미지를 눌렀을때, 프로필로 이동하지 않았던 버그

- 해결방법: 인스타그램클론때 해결하면서 배웠던, TableView가 cell 크기를 계산할 때에는 contentView에 추가된 subview들을 기준으로 한다는걸 적용하여 수정해주었다.

전

![Oct-27-2022_15-46-43](https://github.com/choijaegwon/choijaegwon.github.io/assets/68246962/fbc87ac1-faf3-4003-aced-f462cac46511)  

후

![Oct-27-2022_15-47-11](https://github.com/choijaegwon/choijaegwon.github.io/assets/68246962/a3881933-1b2c-42e2-b9ff-d9002a27c25c)  

### 시연연상

![Oct-31-2022_03-53-34](https://github.com/choijaegwon/choijaegwon.github.io/assets/68246962/9e554514-68c8-4637-a6da-1150f71ba78f)  

![Oct-31-2022_01-59-51](https://github.com/choijaegwon/choijaegwon.github.io/assets/68246962/732dd936-fa3e-43b8-8995-d9eaf1d78c95)  

![Oct-31-2022_01-59-59](https://github.com/choijaegwon/choijaegwon.github.io/assets/68246962/38c9ac19-c1bf-4616-bd40-54a9f0f4352b)  
