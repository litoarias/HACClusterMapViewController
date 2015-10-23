//
//  HACQuadTree.h
//  HAClusterMapView
//
//  Created by Hipolito Arias on 14/10/15.
//  Copyright © 2015 MasterApp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct HACQuadTreeNodeData {
    double x;
    double y;
    void* data;
} HACQuadTreeNodeData;
HACQuadTreeNodeData HACQuadTreeNodeDataMake(double x, double y, void* data);

typedef struct HACBoundingBox {
    double x0; double y0;
    double xf; double yf;
} HACBoundingBox;
HACBoundingBox HACBoundingBoxMake(double x0, double y0, double xf, double yf);

typedef struct quadTreeNode {
    struct quadTreeNode* northWest;
    struct quadTreeNode* northEast;
    struct quadTreeNode* southWest;
    struct quadTreeNode* southEast;
    HACBoundingBox boundingBox;
    int bucketCapacity;
    HACQuadTreeNodeData *points;
    int count;
} HACQuadTreeNode;
HACQuadTreeNode* HACQuadTreeNodeMake(HACBoundingBox boundary, int bucketCapacity);

void HACFreeQuadTreeNode(HACQuadTreeNode* node);

bool HACBoundingBoxContainsData(HACBoundingBox box, HACQuadTreeNodeData data);
bool HACBoundingBoxIntersectsBoundingBox(HACBoundingBox b1, HACBoundingBox b2);

typedef void(^HACQuadTreeTraverseBlock)(HACQuadTreeNode* currentNode);
void HACQuadTreeTraverse(HACQuadTreeNode* node, HACQuadTreeTraverseBlock block);

typedef void(^HACDataReturnBlock)(HACQuadTreeNodeData data);
void HACQuadTreeGatherDataInRange(HACQuadTreeNode* node, HACBoundingBox range, HACDataReturnBlock block);

bool HACQuadTreeNodeInsertData(HACQuadTreeNode* node, HACQuadTreeNodeData data);
HACQuadTreeNode* HACQuadTreeBuildWithData(HACQuadTreeNodeData *data, int count, HACBoundingBox boundingBox, int capacity);
