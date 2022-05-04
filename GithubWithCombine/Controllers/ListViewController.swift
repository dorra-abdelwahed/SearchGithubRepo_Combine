//
//  ViewController.swift
//  GithubWithCombine
//
//  Created by Dorra Ben Abdelwahed on 25/4/2022.
//


import UIKit
import Combine
import SafariServices


class ListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let githubService = GithubService()
    private var cancellable: AnyCancellable?
    private var subscription = Set<AnyCancellable>()
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    @Published var searchText = ""
    
    private var repos: [Repo] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    

  
    
    override func viewDidLoad() {
        super.viewDidLoad()
              
        tableView.delegate = self
        tableView.dataSource = self
        
        //Register cell
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CustomTableViewCell")
        
        setupSearchController()
        setupSearchSubscriber()
        
       
    }
    
    
    private func setupSearchSubscriber() {
        $searchText
        //Only start searching when there's more than 2 characters of input
            .filter { $0.count > 2 }
        // removes spaces from the string
            .map({ $0.replacingOccurrences(of: " ", with: "")})
            .sink { searchField in
                self.fetchRepos(matching: searchField)
            }
            .store(in: &subscription)
    }

    private func fetchRepos(matching query: String) {
        
       
        cancellable = githubService
            .search(matching: query)
        //Just show an empty list when an error occurs
            .catch { _ in Just([]) }
        // Schedule to receive the assign on the main dispatch queue.
            .receive(on: DispatchQueue.main)
        //Subscription life cycle
            .handleEvents(receiveSubscription: { _ in
                self.activityIndicator.startAnimating()

            }, receiveCompletion: { _ in
                self.activityIndicator.stopAnimating()
            }, receiveCancel: {
                self.activityIndicator.stopAnimating()
                
            })
            .assign(to: \.repos, on: self)
    }
    
    private func openLink(_ url: URL) {
            
            // Present SFSafariViewController
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate{
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repos.count
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as? CustomTableViewCell else { return UITableViewCell() }
        
        cell.titleLbl.text = repos[indexPath.row].name
        cell.descriptionLbl.text = repos[indexPath.row].description
        cell.starLbl.text = String(repos[indexPath.row].stargazers_count)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let url = repos[indexPath.row].html_url
        self.openLink(url)

    }
}

extension ListViewController{
    
    private func setupSearchController() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false

        let searchTextField: UITextField? = searchController.searchBar.value(forKey: "searchField") as? UITextField
        searchTextField?.attributedPlaceholder = NSAttributedString(string: "Search for repository", attributes: [.foregroundColor: UIColor.gray])
        searchTextField?.textColor = .gray

        navigationItem.searchController = searchController
    }
}

extension ListViewController: UISearchResultsUpdating{

    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
    }
}
