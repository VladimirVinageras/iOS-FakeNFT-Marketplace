//
//  MyNFTViewController.swift
//  FakeNFT
//
//  Created by Lolita Chernysheva on 09.08.2024.
//  
//

import UIKit
import SnapKit

protocol MyNFTViewProtocol: AnyObject {
    func display(data: MyNFTScreenModel, reloadData: Bool)
}

final class MyNFTViewController: UIViewController {
    
    typealias Cell = MyNFTScreenModel.TableData.Cell
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        return tableView
    }()
    
    var presenter: MyNFTPresenterProtocol!
    
    private var screenModel: MyNFTScreenModel = .empty {
        didSet {
            setup()
        }
    }
    
    //MARK: life cycle methods
    
    override func viewWillAppear(_ animated: Bool) {
        presenter.setup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        hidesBottomBarWhenPushed = true
        setupTableView()
        setupView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NFTTableViewCell.self, forCellReuseIdentifier: NFTTableViewCell.identifier)
    }
    
    private func setupView() {
        view.addSubview(tableView)
        configureTableView()
        configureNavBar()
    }
    
    private func configureTableView() {
        tableView.backgroundColor = .white
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(-CGFloat.horizontalOffset)
            make.leading.equalToSuperview().offset(CGFloat.horizontalOffset)
            make.bottom.equalToSuperview()
        }
    }
    
    private func configureNavBar() {
        let backButton = UIButton(type: .custom)
        let rightButton = UIButton(type: .custom)
        
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        let rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        
        backButton.setImage(Asset.Images.backward, for: .normal)
        rightButton.setImage(Asset.Images.sort, for: .normal)
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)

        self.navigationItem.leftBarButtonItem = backBarButtonItem
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
    }
    
    private func setup() {
        title = screenModel.title
    }
    
    private func tableDataCell(indexPath: IndexPath) -> Cell {
        let section = screenModel.tableData.sections[indexPath.section]
        switch section {
        case let .simple(cells):
            return cells[indexPath.row]
        }
    }
    
    private func showActionSheet() {
        let actionSheet = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "По цене", style: .default, handler: { _ in
            print("Сортировка по цене")
        }))
        actionSheet.addAction(UIAlertAction(title: "По рейтингу", style: .default, handler: { _ in
            print("Сортировка по рейтингу")
        }))
        actionSheet.addAction(UIAlertAction(title: "По названию", style: .default, handler: { _ in
            print("Сортировка по названию")
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func sortButtonTapped() {
        showActionSheet()
    }
}

extension MyNFTViewController: MyNFTViewProtocol {
    func display(data: MyNFTScreenModel, reloadData: Bool) {
        screenModel = data
        if reloadData {
            tableView.reloadData()
        }
        
    }
}

//MARK: - UITableViewDelegate

extension MyNFTViewController: UITableViewDelegate {
    
}

//MARK: - UITableViewDataSource

extension MyNFTViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = tableDataCell(indexPath: indexPath)
        let cell: UITableViewCell
        
        switch cellType {
        case let .nftCell(model):
            guard let nftCell = tableView.dequeueReusableCell(withIdentifier: NFTTableViewCell.identifier, for: indexPath) as? NFTTableViewCell else { return UITableViewCell() }
            nftCell.model = model
            cell = nftCell
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        screenModel.tableData.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch screenModel.tableData.sections[section] {
        case let .simple(cells):
            return cells.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        .cellHeight
    }
    
}

private extension CGFloat {
    static let horizontalOffset = 16.0
    static let cellHeight = 140.0
}
