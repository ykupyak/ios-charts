//
//  ChartDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 23/2/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import UIKit

public class ChartDataSet: NSObject
{
    public var colors = [UIColor]()
    internal var _yVals: [ChartDataEntry]!
    internal var _yMax = Float(0.0)
    internal var _yMin = Float(0.0)
    internal var _yValueSum = Float(0.0)
    public var label = "DataSet"
    public var visible = true;
    public var drawValuesEnabled = true;
    
    /// the color used for the value-text
    public var valueTextColor: UIColor = UIColor.blackColor()
    
    /// the font for the value-text labels
    public var valueFont: UIFont = UIFont.systemFontOfSize(7.0)
    
    /// the formatter used to customly format the values
    public var valueFormatter: NSNumberFormatter?
    
    /// the axis this DataSet should be plotted against.
    public var axisDependency = ChartYAxis.AxisDependency.Left

    public var yVals: [ChartDataEntry] { return _yVals }
    public var yValueSum: Float { return _yValueSum }
    public var yMin: Float { return _yMin }
    public var yMax: Float { return _yMax }
    
    public override init()
    {
        super.init();
    }
    
    public init(yVals: [ChartDataEntry]?, label: String)
    {
        super.init();
        
        self.label = label;
        _yVals = yVals == nil ? [ChartDataEntry]() : yVals;
        
        // default color
        colors.append(UIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0));
        
        self.calcMinMax();
        self.calcYValueSum();
    }
    
    public convenience init(yVals: [ChartDataEntry]?)
    {
        self.init(yVals: yVals, label: "DataSet")
    }
    
    internal func calcMinMax()
    {
        if _yVals!.count == 0
        {
            return;
        }
        
        _yMin = yVals[0].value;
        _yMax = yVals[0].value;
        
        for var i = 0; i < _yVals.count; i++
        {
            let e = _yVals[i];
            if (e.value < _yMin)
            {
                _yMin = e.value;
            }
            if (e.value > _yMax)
            {
                _yMax = e.value;
            }
        }
    }
    
    private func calcYValueSum()
    {
        _yValueSum = 0;
        
        for var i = 0; i < _yVals.count; i++
        {
            _yValueSum += fabsf(_yVals[i].value);
        }
    }
    
    public var entryCount: Int { return _yVals!.count; }
    
    public func yValForXIndex(x: Int) -> Float
    {
        let e = self.entryForXIndex(x);
        
        if (e !== nil) { return e.value }
        else { return Float.NaN }
    }
    
    /// Returns the first Entry object found at the given xIndex with binary search. 
    /// If the no Entry at the specifed x-index is found, this method returns the Entry at the closest x-index. 
    /// Returns nil if no Entry object at that index.
    public func entryForXIndex(x: Int) -> ChartDataEntry!
    {
        var index = self.entryIndex(xIndex: x);
        if (index > -1)
        {
            return _yVals[index];
        }
        return nil;
    }
    
    public func entriesForXIndex(x: Int) -> [ChartDataEntry]
    {
        var entries = [ChartDataEntry]();
        
        var low = 0;
        var high = _yVals.count - 1;
        
        while (low <= high)
        {
            var m = Int((high + low) / 2);
            var entry = _yVals[m];
            
            if (x == entry.xIndex)
            {
                while (m > 0 && _yVals[m - 1].xIndex == x)
                {
                    m--;
                }
                
                high = _yVals.count;
                for (; m < high; m++)
                {
                    entry = _yVals[m];
                    if (entry.xIndex == x)
                    {
                        entries.append(entry);
                    }
                    else
                    {
                        break;
                    }
                }
            }
            
            if (x > _yVals[m].xIndex)
            {
                low = m + 1;
            }
            else
            {
                high = m - 1;
            }
        }
        
        return entries;
    }
    
    public func entryIndex(xIndex x: Int) -> Int
    {
        var low = 0;
        var high = _yVals.count - 1;
        var closest = -1;
        
        while (low <= high)
        {
            var m = (high + low) / 2;
            var entry = _yVals[m];
            
            if (x == entry.xIndex)
            {
                while (m > 0 && _yVals[m - 1].xIndex == x)
                {
                    m--;
                }
                
                return m;
            }
            
            if (x > entry.xIndex)
            {
                low = m + 1;
            }
            else
            {
                high = m - 1;
            }
            
            closest = m;
        }
        
        return closest;
    }
    
    public func entryIndex(entry e: ChartDataEntry, isEqual: Bool) -> Int
    {
        if (isEqual)
        {
            for (var i = 0; i < _yVals.count; i++)
            {
                if (_yVals[i].isEqual(e))
                {
                    return i;
                }
            }
        }
        else
        {
            for (var i = 0; i < _yVals.count; i++)
            {
                if (_yVals[i] === e)
                {
                    return i;
                }
            }
        }
        
        return -1
    }
    
    /// Returns the number of entries this DataSet holds.
    public var valueCount: Int { return _yVals.count; }

    public func addEntry(e: ChartDataEntry)
    {
        var val = e.value;
        
        if (_yVals == nil)
        {
            _yVals = [ChartDataEntry]();
        }
        
        if (_yVals.count == 0)
        {
            _yMax = val;
            _yMin = val;
        }
        else
        {
            if (_yMax < val)
            {
                _yMax = val;
            }
            if (_yMin > val)
            {
                _yMin = val;
            }
        }
        
        _yValueSum += val;
        
        _yVals.append(e);
    }
    
    public func removeEntry(entry: ChartDataEntry) -> Bool
    {
        var removed = false;
        
        for (var i = 0; i < _yVals.count; i++)
        {
            if (_yVals[i] === entry)
            {
                _yVals.removeAtIndex(i);
                removed = true;
                break;
            }
        }
        
        if (removed)
        {
            _yValueSum -= entry.value;
            calcMinMax();
        }
        
        return removed;
    }
    
    public func removeEntry(#xIndex: Int) -> Bool
    {
        var index = self.entryIndex(xIndex: xIndex);
        if (index > -1)
        {
            var e = _yVals.removeAtIndex(index);
            
            _yValueSum -= e.value;
            calcMinMax();
            
            return true;
        }
        
        return false;
    }
    
    public func resetColors()
    {
        colors.removeAll(keepCapacity: false);
    }
    
    public func addColor(color: UIColor)
    {
        colors.append(color);
    }
    
    public func setColor(color: UIColor)
    {
        colors.removeAll(keepCapacity: false);
        colors.append(color);
    }
    
    public func colorAt(var index: Int) -> UIColor
    {
        if (index < 0)
        {
            index = 0;
        }
        return colors[index % colors.count];
    }
    
    public var isVisible: Bool
    {
        return visible;
    }
    
    public var isDrawValuesEnabled: Bool
    {
        return drawValuesEnabled;
    }
    
    /// Checks if this DataSet contains the specified Entry. 
    /// :returns: true if contains the entry, false if not. 
    public func contains(e: ChartDataEntry) -> Bool
    {
        for entry in _yVals
        {
            if (entry.isEqual(e))
            {
                return true;
            }
        }
        
        return false;
    }

    // MARK: NSObject
    
    public override var description: String
    {
        return String(format: "ChartDataSet, label: %@, %i entries", arguments: [self.label, _yVals.count]);
    }
    
    public override var debugDescription: String
    {
        var desc = description + ":";
        
        for (var i = 0; i < _yVals.count; i++)
        {
            desc += "\n" + _yVals[i].description;
        }
        
        return desc;
    }
    
    // MARK: NSCopying
    
    public func copyWithZone(zone: NSZone) -> AnyObject
    {
        var copy = self.dynamicType.allocWithZone(zone) as ChartDataSet;
        copy.colors = colors;
        copy._yVals = _yVals;
        copy._yMax = _yMax;
        copy._yMin = _yMin;
        copy._yValueSum = _yValueSum;
        copy.label = self.label;
        return copy;
    }
}


