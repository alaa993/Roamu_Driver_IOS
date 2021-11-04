//
//  PostDetailsViewController.swift
//  Taxi
//
//  Created by ibrahim.marie on 6/13/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import UIKit
import Firebase

class PostDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    //    var tableView:UITableView!
    @IBOutlet var PostTableView: UITableView!
    
    @IBOutlet var CommentButton: UIButton!
    //    @IBOutlet var TripDetailsButton: UIButton!
    
    //    @IBOutlet var CommentTextField: UITextField!
    
    @IBOutlet var CommentTextView: UITextView!
    
    @IBOutlet var CommentsTableView: UITableView!
    var cellHeights: [IndexPath : CGFloat] = [:]
    var posts = [Post]()
    var fetchingMore = false
    var endReached = false
    let leadingScreensForBatching:CGFloat = 3.0
    
    var refreshControl:UIRefreshControl!
    
    var seeNewPostsButton:SeeNewPostsButton!
    var seeNewPostsButtonTopAnchor:NSLayoutConstraint!
    
    var lastUploadedPostID:String?
    
    var postsRef:DatabaseReference {
        return Database.database().reference().child("posts").child(self.post[0].id).child("Comments")
        //        return Database.database().reference().child("posts")
    }
    
    var oldPostsQuery:DatabaseQuery {
        var queryRef:DatabaseQuery
        let lastPost = posts.last
        if lastPost != nil {
            let lastTimestamp = lastPost!.createdAt.timeIntervalSince1970 * 1000
            queryRef = postsRef.queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestamp)
        } else {
            queryRef = postsRef.queryOrdered(byChild: "timestamp")
        }
        return queryRef
    }
    
    var newPostsQuery:DatabaseQuery {
        var queryRef:DatabaseQuery
        let firstPost = posts.first
        if firstPost != nil {
            let firstTimestamp = firstPost!.createdAt.timeIntervalSince1970 * 1000
            queryRef = postsRef.queryOrdered(byChild: "timestamp").queryStarting(atValue: firstTimestamp)
        } else {
            queryRef = postsRef.queryOrdered(byChild: "timestamp")
        }
        return queryRef
    }
    
    //var VCpost = [Post]()
    var post = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CommentButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "PostDetailsVC_CommentButton", comment: ""), for: .normal)
        
        // the original post
        let cellNib = UINib(nibName: "PostTableViewCell", bundle: nil)
        PostTableView.register(cellNib, forCellReuseIdentifier: "postCell")
        PostTableView.backgroundColor = UIColor(white: 0.90,alpha:1.0)
        PostTableView.delegate = self
        PostTableView.dataSource = self
        PostTableView.reloadData()
        
        // the comments
        let cellNib2 = UINib(nibName: "CommentTableViewCell", bundle: nil)
        CommentsTableView.register(cellNib2, forCellReuseIdentifier: "postCell")
        CommentsTableView.register(LoadingCell.self, forCellReuseIdentifier: "loadingCell")
        CommentsTableView.backgroundColor = UIColor(white: 0.90,alpha:1.0)
        //        view.addSubview(CommentsTableView)
        
        var layoutGuide:UILayoutGuide!
        CommentTextView.delegate = self
        
        if #available(iOS 11.0, *) {
            layoutGuide = view.safeAreaLayoutGuide
        } else {
            // Fallback on earlier versions
            layoutGuide = view.layoutMarginsGuide
        }
        
        CommentsTableView.delegate = self
        CommentsTableView.dataSource = self
        CommentsTableView.reloadData()
        
        refreshControl = UIRefreshControl()
        if #available(iOS 10.0, *) {
            CommentsTableView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
            CommentsTableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        
        seeNewPostsButton = SeeNewPostsButton()
        view.addSubview(seeNewPostsButton)
        seeNewPostsButton.translatesAutoresizingMaskIntoConstraints = false
        seeNewPostsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        seeNewPostsButtonTopAnchor = seeNewPostsButton.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: -44)
        seeNewPostsButtonTopAnchor.isActive = true
        seeNewPostsButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        seeNewPostsButton.widthAnchor.constraint(equalToConstant: seeNewPostsButton.button.bounds.width).isActive = true
        
        seeNewPostsButton.button.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        beginBatchFetch()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        listenForNewPosts()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopListeningForNewPosts()
    }
    
    func toggleSeeNewPostsButton(hidden:Bool) {
        if hidden {
            // hide it
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.seeNewPostsButtonTopAnchor.constant = -44.0
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            // show it
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.seeNewPostsButtonTopAnchor.constant = 12
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc func handleRefresh() {
        print("Refresh!")
        
        toggleSeeNewPostsButton(hidden: true)
        
        newPostsQuery.queryLimited(toFirst: 20).observeSingleEvent(of: .value, with: { snapshot in
            var tempPosts = [Post]()
            
            let firstPost = self.posts.first
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let data = childSnapshot.value as? [String:Any],
                    let post = Post.parse(childSnapshot.key, data),
                    childSnapshot.key != firstPost?.id {
                    
                    tempPosts.insert(post, at: 0)
                }
            }
            
            self.posts.insert(contentsOf: tempPosts, at: 0)
            
            let newIndexPaths = (0..<tempPosts.count).map { i in
                return IndexPath(row: i, section: 0)
            }
            
            self.refreshControl.endRefreshing()
            self.CommentsTableView.insertRows(at: newIndexPaths, with: .top)
            self.CommentsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            
            self.listenForNewPosts()
            
        })
    }
    
    func fetchPosts(completion:@escaping (_ posts:[Post])->()) {
        
        oldPostsQuery.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { snapshot in
            var tempPosts = [Post]()
            
            let lastPost = self.posts.last
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let data = childSnapshot.value as? [String:Any],
                    let post = Post.parse(childSnapshot.key, data),
                    childSnapshot.key != lastPost?.id {
                    
                    tempPosts.insert(post, at: 0)
                }
            }
            
            return completion(tempPosts)
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == PostTableView{
            return 1
        } else if tableView == CommentsTableView{
            if posts.count == 0 {
                setEmptyView(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "PostDetailsVC_Comments1", comment: ""), message: LocalizationSystem.sharedInstance.localizedStringForKey(key: "PostDetailsVC_Comments2", comment: ""))
            }
            else{
                restore()
            }
            
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == PostTableView{
            return post.count
        } else if tableView == CommentsTableView{
            switch section {
            case 0:
                return posts.count
            case 1:
                return fetchingMore ? 1 : 0
            default:
                return 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == PostTableView{
            let cellNib = UINib(nibName: "PostTableViewCell", bundle: nil)
            tableView.register(cellNib, forCellReuseIdentifier: "postCell")
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
            cell.commentsLabel.isHidden = true
            if (self.post[0].type == "0" && self.post[0].travel_id > 0)
            {
                cell.AboutButton.isHidden = false
                cell.edit_post.isHidden = true
                
            }
            else{
                cell.AboutButton.isHidden = true
                cell.edit_post.isHidden = false
            }
            if (self.post[0].author.uid == Auth.auth().currentUser?.uid){
                cell.edit_post.isHidden = false
            }else{
                cell.edit_post.isHidden = true
            }
            cell.iii.backgroundColor = UIColor.init(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0)
            cell.postTextView.font = UIFont.init(name: "Times New Roman", size: 20)
            cell.postTextView.isEditable = false
            cell.postTextView.isUserInteractionEnabled = false
            cell.postTextView.backgroundColor = UIColor.init(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0)
            var count = 0
            let userRef = Database.database().reference().child("posts").child(self.post[0].id).child("Comments")
            userRef.observe(.value, with: { snapshot in
                count = Int(snapshot.childrenCount)
                cell.set(post: self.post[0], CommentsNo: count, subStoryboard:self.storyboard!, subNavigationVC: self.navigationController!)
            })
            return cell
        } else if tableView == CommentsTableView{
            
            let cellNib = UINib(nibName: "CommentTableViewCell", bundle: nil)
            tableView.register(cellNib, forCellReuseIdentifier: "postCell")
            
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! CommentTableViewCell
                let userRef = Database.database().reference().child("posts").child(posts[indexPath.row].id).child("Comments")
                userRef.observe(.value, with: { snapshot in
                    cell.set(post: self.posts[indexPath.row])
                    
                })
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
                cell.spinner.startAnimating()
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath] ?? 72.0
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height * leadingScreensForBatching {
            
            if !fetchingMore && !endReached {
                beginBatchFetch()
            }
        }
    }
    
    func beginBatchFetch() {
        fetchingMore = true
        self.CommentsTableView.reloadSections(IndexSet(integer: 1), with: .fade)
        
        fetchPosts { newPosts in
            self.posts.append(contentsOf: newPosts)
            self.fetchingMore = false
            self.endReached = newPosts.count == 0
            UIView.performWithoutAnimation {
                self.CommentsTableView.reloadData()
                
                self.listenForNewPosts()
            }
        }
    }
    
    var postListenerHandle:UInt?
    
    func listenForNewPosts() {
        
        guard !fetchingMore else { return }
        
        // Avoiding duplicate listeners
        stopListeningForNewPosts()
        
        postListenerHandle = newPostsQuery.observe(.childAdded, with: { snapshot in
            
            if snapshot.key != self.posts.first?.id,
                let data = snapshot.value as? [String:Any],
                let post = Post.parse(snapshot.key, data) {
                
                //self.stopListeningForNewPosts()
                
                if snapshot.key == self.lastUploadedPostID {
                    self.handleRefresh()
                    self.lastUploadedPostID = nil
                } else {
                    self.toggleSeeNewPostsButton(hidden: false)
                }
            }
        })
    }
    
    func stopListeningForNewPosts() {
        if let handle = postListenerHandle {
            newPostsQuery.removeObserver(withHandle: handle)
            postListenerHandle = nil
        }
    }
    
    // post
    @IBAction func CommentButtonClicked(_ sender: Any) {
        handleCommentButton()
    }
    
    //    @IBAction func TripDetailsButtonClicked(_ sender: Any) {
    //        let vcConfirm = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmRideVC") as! ConfirmRideVC
    //        vcConfirm.confirmRequestPage = confirmRequestView.PlatformViewController
    //        print(String(self.post[0].travel_id))
    //        vcConfirm.travel_id_var = String(self.post[0].travel_id)
    //        self.navigationController?.pushViewController(vcConfirm, animated: true)
    //    }
    
    
    func observePosts() {
        Database.database().reference().child("posts").child(self.post[0].id).observe(.value, with: { snapshot in
            for child in snapshot.children {
                print("ibrahim")
                print(snapshot)
                if let childSnapshot = child as? DataSnapshot,
                    let dict = childSnapshot.value as? [String:Any],
                    let author = dict["author"] as? [String:Any],
                    let uid = author["uid"] as? String,
                    let username = author["username"] as? String,
                    let photoURL = author["photoURL"] as? String,
                    let url = URL(string:photoURL),
                    let text = dict["text"] as? String,
                    let type = dict["type"] as? String,
                    let travel_id = dict["travel_id"] as? Double,
                    let timestamp = dict["timestamp"] as? Double {
                    let userProfile = UserProfile(uid: uid, username: username, photoURL: url)
                    let post = Post(id: childSnapshot.key, author: userProfile, text: text, timestamp:timestamp,type: type, travel_id:Int(travel_id))
                }
            }
        })
    }
    
    func handleCommentButton() {
        if CommentTextView.text.count > 0
        {
            guard let userProfile = UserService.currentUserProfile else { return }
            // Firebase code here
            
            let postRef = Database.database().reference().child("posts").child(self.post[0].id).child("Comments").childByAutoId()
            let postObject = [
                "author": [
                    "uid": userProfile.uid,
                    "username": userProfile.username,
                    "photoURL": userProfile.photoURL.absoluteString
                ],
                "text": CommentTextView.text!,//"comment1 test",
                "timestamp": [".sv":"timestamp"],
                "type":"0",
                "travel_id": 0
                ] as [String:Any]
            
            postRef.setValue(postObject, withCompletionBlock: { error, ref in
                if error == nil {
                    //                   self.delegate?.didUploadPost(withID: ref.key!)
                    //                   self.dismiss(animated: true, completion: nil)
                    self.CommentTextView.text = ""
                } else {
                    
                    // Handle the error
                }
            })
        }
    }
    
}
extension PostDetailsViewController {
    
    func setEmptyView(title: String, message: String) {
        
        let emptyView = UIView(frame: CGRect(x: self.CommentsTableView.center.x, y: self.CommentsTableView.center.y, width: self.CommentsTableView.bounds.size.width, height: self.CommentsTableView.bounds.size.height))
        
        let messageImageView = UIImageView()
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        
        messageImageView.backgroundColor = .clear
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageImageView)
        emptyView.addSubview(messageLabel)
        
        messageImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageImageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -20).isActive = true
        messageImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        messageImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: messageImageView.bottomAnchor, constant: 10).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        messageLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        //        messageImageView.image = messageImage
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        UIView.animate(withDuration: 1, animations: {
            
            messageImageView.transform = CGAffineTransform(rotationAngle: .pi / 10)
        }, completion: { (finish) in
            UIView.animate(withDuration: 1, animations: {
                messageImageView.transform = CGAffineTransform(rotationAngle: -1 * (.pi / 10))
            }, completion: { (finishh) in
                UIView.animate(withDuration: 1, animations: {
                    messageImageView.transform = CGAffineTransform.identity
                })
            })
            
        })
        
        self.CommentsTableView.backgroundView = emptyView
        self.CommentsTableView.separatorStyle = .none
    }
    
    func restore() {
        
        self.CommentsTableView.backgroundView = nil
        self.CommentsTableView.separatorStyle = .singleLine
        
    }
}
