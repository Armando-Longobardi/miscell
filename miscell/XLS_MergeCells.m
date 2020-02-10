function XLS_MergeCells(Range)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

Range.HorizontalAlignment = -4108;
% Range.VerticalAlignment = 'xlBottom';
Range.WrapText = 0;
Range.Orientation = 0;
Range.AddIndent = 0;
Range.IndentLevel = 0;
Range.ShrinkToFit = 0;
% Range.ReadingOrder = 'xlContext';
Range.MergeCells = 1;

% Selection.Merge
end

