//
//  SnappingFlowLayout.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/26/23.
//

import UIKit
import SwiftUI

// Custom UICollectionViewFlowLayout
class SnappingFlowLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }

        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }

        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalCenter = proposedContentOffset.x + (collectionView.bounds.width / 2)

        for layoutAttributes in rectAttributes {
            let itemHorizontalCenter = layoutAttributes.center.x
            if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }

        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
    
    override init() {
        super.init()
        self.scrollDirection = .horizontal
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//Cell
class DateCell: UICollectionViewCell {
    var dateLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        dateLabel = UILabel(frame: bounds)
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with date: Date, isSelected: Bool) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        dateLabel.text = formatter.string(from: date)
        dateLabel.textColor = isSelected ? .white : .black
        contentView.backgroundColor = isSelected ? .blue : .clear
    }
}

//View Controller
class DateCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var collectionView: UICollectionView!
    var dates: [Date] = []
    var selectedDate: Date {
        didSet {
            // Update the collection view when the selected date changes
            collectionView.reloadData()
            scrollToSelectedDate(animated: false)
        }
    }
    var selectionManager: DateSelectionManager

    init(selectionManager: DateSelectionManager) {
        self.selectionManager = selectionManager
        self.selectedDate = selectionManager.selectedDate
        super.init(nibName: nil, bundle: nil)
        loadDates()
        setupCollectionView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadDates() {
            let today = Date()
            let range = -365...365 // Adjust as needed
            dates = range.compactMap { Calendar.current.date(byAdding: .day, value: $0, to: today) }
    }
    private func setupCollectionView() {
        let layout = SnappingFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as? DateCell else {
            return UICollectionViewCell()
        }
        let date = dates[indexPath.row]
        cell.configure(with: date, isSelected: date == selectedDate)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let date = dates[indexPath.row]
        selectedDate = date
        selectionManager.selectedDate = date
    }

    private func scrollToSelectedDate(animated: Bool) {
        if let selectedIndex = dates.firstIndex(of: selectedDate) {
            collectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: animated)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}
