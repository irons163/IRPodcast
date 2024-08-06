//
//  FavoritesViewController.swift
//  IRPodcast
//
//  Created by Phil on 2021/4/27.
//

import UIKit

final class FavoritesViewController: UICollectionViewController {

    // MARK: - Properties
    private let reuseIdentifier = "FavoritePodcastCell"
    private let viewModel: FavoritesViewModel
    private lazy var dataSource: CollectionViewDataSource = {
        CollectionViewDataSource.makeAndRegister(for: viewModel.podcasts, on: collectionView)
    }()

    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.viewModel.onDataUpdated = { [weak self] in
           guard let self else { return }

           self.dataSource.update(with: self.viewModel.podcasts)

           self.collectionView.reloadData()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()
        UIApplication.mainTabBarController?.viewControllers?[1].tabBarItem.badgeValue = nil
    }
}

// MARK: - Collection View
extension FavoritesViewController {

    // MARK: - Navigation
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let podcast = viewModel.podcasts[indexPath.item]
        let episodesViewModel = EpisodesViewModel(podcast: podcast)
        let episodesController = EpisodesViewController(viewModel: episodesViewModel)
        navigationController?.pushViewController(episodesController, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FavoritesViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3 * 16) / 2
        return CGSize(width: width, height: width + 46)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

// MARK: - Setup
extension FavoritesViewController {

    private func setupCollectionView() {
        collectionView.dataSource = dataSource
        collectionView.backgroundColor = .white
        collectionView.register(FavoritePodcastCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        collectionView.addGestureRecognizer(gesture)
    }

    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: collectionView)
        guard let selectedIndexPath = collectionView?.indexPathForItem(at: location) else { return }
        print(selectedIndexPath.item)

        let alertController = UIAlertController(title: "Remove podcast?", message: nil, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] _ in
            guard let self else {
                return
            }
            let selectedPodcast = viewModel.podcasts[selectedIndexPath.item]
            viewModel.deletePodcast(at: selectedIndexPath.item)
            collectionView?.deleteItems(at: [selectedIndexPath])
            UserDefaults.standard.deletePodcast(selectedPodcast)
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alertController, animated: true)
    }
}
