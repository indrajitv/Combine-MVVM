//
//  MovieListCell.swift
//  CombineMVVM
//
//  Created by Indrajit Chavda on 14/12/22.
//

import UIKit
import Combine

final class MovieListCell: UITableViewCell {

    static let cellID: String = "MovieListCell"

    private var viewModel: MovieListCellViewModel?
    private var subscriptions = Set<AnyCancellable>()

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body, compatibleWith: .current)
        label.textColor = .label
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = .preferredFont(forTextStyle: .caption1, compatibleWith: .current)
        label.textColor = .secondaryLabel
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setUpViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.titleLabel.text = nil
        self.descriptionLabel.text = nil
        self.posterImageView.image = nil
        self.subscriptions.removeAll()
    }

    private func setUpViews() {
        self.addSubview(self.posterImageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.descriptionLabel)

        let padding: CGFloat = 12
        let imageSize: CGFloat = 70

        NSLayoutConstraint.activate([
            self.posterImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            self.posterImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            self.posterImageView.heightAnchor.constraint(equalToConstant: imageSize),
            self.posterImageView.widthAnchor.constraint(equalToConstant: imageSize),

            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.posterImageView.trailingAnchor, constant: padding),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),

            self.descriptionLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: padding),
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.posterImageView.trailingAnchor, constant: padding),
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),
            self.descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -padding),
        ])
    }

    private func subscribe() {
        self.viewModel?.$title.map({ $0 })
            .assign(to: \.text, on: self.titleLabel)
            .store(in: &self.subscriptions)

        self.viewModel?.$description.map({ $0 })
            .assign(to: \.text, on: self.descriptionLabel)
            .store(in: &self.subscriptions)

        self.viewModel?.loadPosterImage()?
            .assign(to: \.image, on: self.posterImageView)
            .store(in: &self.subscriptions)
    }

    func configureCell(from viewModel: MovieListCellViewModel) {
        self.viewModel = viewModel
        self.subscribe()
    }
}
