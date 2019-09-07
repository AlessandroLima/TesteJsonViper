//
//  RepositoriesViewController.swift
//  TesteJson
//
//  Created by Alessandro on 06/09/19.
//  Copyright © 2019 Alessandro. All rights reserved.
//

import UIKit

class RepositoriesViewController: UIViewController, UISearchBarDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var txtSearch: UISearchBar!
    @IBOutlet weak var viLoad: UIView!
    @IBOutlet weak var aiLoad: UIActivityIndicatorView!
    
    //MARK: Properties
    
    var repository:GitHubEntity?
    var repositoryItens:[Item] = []
    let cellIdentifier = "cell"
    
    
    //MARK: ViewFunctions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        txtSearch.delegate = self
        loadRepositories(language: "")
        
        tableView.register(UINib(nibName: "RepositoriesTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        
    }
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        txtSearch.resignFirstResponder()
        txtSearch.text = ""
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = txtSearch.text{
            setload(true)
            loadRepositories(language: text)
        }
        txtSearch.resignFirstResponder()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        txtSearch.text = ""
    }
}

extension RepositoriesViewController{
    
    //MARK: Functions
    
    func loadRepositories(language:String){
        Repository.loadRepositories(language:language,onComplete: { (repository) in
            
            self.reloadView(repository: repository)
            
        }) { (error) in
            self.showAlert()
            self.showError(error: error)
        }
    }
    
    func setload(_ hasConfirmation:Bool){
        if !hasConfirmation{
            self.aiLoad.stopAnimating()
            self.viLoad.isHidden = true
            self.aiLoad.hidesWhenStopped = true
        }else{
            self.aiLoad.startAnimating()
            self.viLoad.isHidden = false
            self.aiLoad.hidesWhenStopped = false
        }
    }
    
    func reloadView(repository:GitHubEntity){
        self.repository = repository
        self.repositoryItens = repository.items
        DispatchQueue.main.async {
            self.setload(false)
            self.tableView.reloadData()
        }
    }
    
    func showAlert(){
        DispatchQueue.main.async {
            Utils.showAlert(title: "Erro", message: "Ocorreu um erro, ou a linguagem de progamação não existe.", confirmation: false, vc: self)
            self.loadRepositories(language: "")
        }
    }
    
    func showError(error:RepositoryError){
        switch error{
        case .url:
            print("Erro de URL")
        case .taskError(let error):
            print("Erro de Tarefa:\(error)")
        case .noResponse:
            print("Sem Resposta")
        case .noData:
            print("Sem nenhum JSON")
        case .responseStatusCode(let code):
            print("Erro Servidor: \(code)")
        case .invalidJson:
            print("JSON Inválido")
        }
    }
}

extension RepositoriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: TableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositoryItens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RepositoriesTableViewCell
        let repositoryItem = repositoryItens[indexPath.row]
        
        cell.lblLogin.text = repositoryItem.owner.login
        cell.lblName.text = repositoryItem.name
        cell.lblStars.text = String(repositoryItem.stargazers_count)
        cell.imgOwner.downloaded(from: repositoryItem.owner.avatar_url)
        
        return cell
    }
    
    
    
    
}
