//
//  RepoCell.swift
//  YouGovTest
//
//  Created by Sourabh Singh on 29/09/21.
//

import Foundation
import Cartography
import Combine

class RepoCell: UITableViewCell {

    let repoOwnerImage = UIImageView()
    let nameLabel = UILabel()
    let descriptionLabel = UILabel()
    let forkedCountLabel = UILabel()
    let watchersLabel = UILabel()
    let openIssuesCountLabel = UILabel()
    private var anyCancellable: AnyCancellable?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        descriptionLabel.numberOfLines = 0
        contentView.addSubview(repoOwnerImage)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(forkedCountLabel)
        contentView.addSubview(watchersLabel)
        contentView.addSubview(openIssuesCountLabel)

        constrain(repoOwnerImage, nameLabel, descriptionLabel, forkedCountLabel, watchersLabel, openIssuesCountLabel) { repoOwnerImage, nameLabel, descriptionLabel, forkedCountLabel, watchersLabel, openIssuesCountLabel in
            let margin: CGFloat = 16
            repoOwnerImage.top == repoOwnerImage.superview!.top + margin
            repoOwnerImage.leading == repoOwnerImage.superview!.leading + margin
            repoOwnerImage.width == 50
            repoOwnerImage.height == 50
            
            nameLabel.leading == repoOwnerImage.trailing + margin
            nameLabel.trailing == nameLabel.superview!.trailing
            nameLabel.centerY == repoOwnerImage.centerY
            
            descriptionLabel.top == repoOwnerImage.bottom + margin / 2
            descriptionLabel.leading == descriptionLabel.superview!.leading + margin
            descriptionLabel.trailing == descriptionLabel.superview!.trailing - margin
            
            forkedCountLabel.top == descriptionLabel.bottom + margin / 2
            forkedCountLabel.leading == forkedCountLabel.superview!.leading + margin
            forkedCountLabel.trailing == forkedCountLabel.superview!.trailing - margin
            
            watchersLabel.top == forkedCountLabel.bottom + margin / 2
            watchersLabel.leading == forkedCountLabel.leading
            watchersLabel.trailing == forkedCountLabel.trailing
            
            openIssuesCountLabel.top == watchersLabel.bottom + margin / 2
            openIssuesCountLabel.leading == watchersLabel.leading
            openIssuesCountLabel.trailing == watchersLabel.trailing
            openIssuesCountLabel.bottom == openIssuesCountLabel.superview!.bottom - margin
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(from viewModel: RepoViewModel) {
        nameLabel.text = viewModel.name
        descriptionLabel.text = viewModel.description
        forkedCountLabel.text = "Forked Count = \(viewModel.forks)"
        watchersLabel.text = "Watchers = \(viewModel.watchers)"
        openIssuesCountLabel.text = "Open issues count = \(viewModel.openIssues)"
        anyCancellable = viewModel.avatarImage.sink { [unowned self] image in
            DispatchQueue.main.async {
                repoOwnerImage.image = image
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        repoOwnerImage.image = nil
        anyCancellable?.cancel()
    }

}

