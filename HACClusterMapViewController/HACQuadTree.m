//
//  HACQuadTree.m
//  HAClusterMapView
//
//  Created by Hipolito Arias on 14/10/15.
//  Copyright © 2015 MasterApp. All rights reserved.
//

#import "HACQuadTree.h"

#pragma mark - Constructors

HACQuadTreeNodeData HACQuadTreeNodeDataMake(double x, double y, void* data)
{
    HACQuadTreeNodeData d; d.x = x; d.y = y; d.data = data;
    return d;
}

HACBoundingBox HACBoundingBoxMake(double x0, double y0, double xf, double yf)
{
    HACBoundingBox bb; bb.x0 = x0; bb.y0 = y0; bb.xf = xf; bb.yf = yf;
    return bb;
}

HACQuadTreeNode* HACQuadTreeNodeMake(HACBoundingBox boundary, int bucketCapacity)
{
    HACQuadTreeNode* node = malloc(sizeof(HACQuadTreeNode));
    node->northWest = NULL;
    node->northEast = NULL;
    node->southWest = NULL;
    node->southEast = NULL;
    
    node->boundingBox = boundary;
    node->bucketCapacity = bucketCapacity;
    node->count = 0;
    node->points = malloc(sizeof(HACQuadTreeNodeData) * bucketCapacity);
    
    return node;
}

#pragma mark - Bounding Box Functions

bool HACBoundingBoxContainsData(HACBoundingBox box, HACQuadTreeNodeData data)
{
    bool containsX = box.x0 <= data.x && data.x <= box.xf;
    bool containsY = box.y0 <= data.y && data.y <= box.yf;
    
    return containsX && containsY;
}

bool HACBoundingBoxIntersectsBoundingBox(HACBoundingBox b1, HACBoundingBox b2)
{
    return (b1.x0 <= b2.xf && b1.xf >= b2.x0 && b1.y0 <= b2.yf && b1.yf >= b2.y0);
}

#pragma mark - Quad Tree Functions

void HACQuadTreeNodeSubdivide(HACQuadTreeNode* node)
{
    HACBoundingBox box = node->boundingBox;
    
    double xMid = (box.xf + box.x0) / 2.0;
    double yMid = (box.yf + box.y0) / 2.0;
    
    HACBoundingBox northWest = HACBoundingBoxMake(box.x0, box.y0, xMid, yMid);
    node->northWest = HACQuadTreeNodeMake(northWest, node->bucketCapacity);
    
    HACBoundingBox northEast = HACBoundingBoxMake(xMid, box.y0, box.xf, yMid);
    node->northEast = HACQuadTreeNodeMake(northEast, node->bucketCapacity);
    
    HACBoundingBox southWest = HACBoundingBoxMake(box.x0, yMid, xMid, box.yf);
    node->southWest = HACQuadTreeNodeMake(southWest, node->bucketCapacity);
    
    HACBoundingBox southEast = HACBoundingBoxMake(xMid, yMid, box.xf, box.yf);
    node->southEast = HACQuadTreeNodeMake(southEast, node->bucketCapacity);
}

bool HACQuadTreeNodeInsertData(HACQuadTreeNode* node, HACQuadTreeNodeData data)
{
    if (!HACBoundingBoxContainsData(node->boundingBox, data)) {
        return false;
    }
    
    if (node->count < node->bucketCapacity) {
        node->points[node->count++] = data;
        return true;
    }
    
    if (node->northWest == NULL) {
        HACQuadTreeNodeSubdivide(node);
    }
    
    if (HACQuadTreeNodeInsertData(node->northWest, data)) return true;
    if (HACQuadTreeNodeInsertData(node->northEast, data)) return true;
    if (HACQuadTreeNodeInsertData(node->southWest, data)) return true;
    if (HACQuadTreeNodeInsertData(node->southEast, data)) return true;
    
    return false;
}

void HACQuadTreeGatherDataInRange(HACQuadTreeNode* node, HACBoundingBox range, HACDataReturnBlock block)
{
    if (!node) return;
    
    if (!HACBoundingBoxIntersectsBoundingBox(node->boundingBox, range)) return;
    
    
    for (int i = 0; i < node->count; i++) {
        if (HACBoundingBoxContainsData(range, node->points[i])) {
            block(node->points[i]);
        }
    }
    
    if (node->northWest == NULL) {
        return;
    }
    
    HACQuadTreeGatherDataInRange(node->northWest, range, block);
    HACQuadTreeGatherDataInRange(node->northEast, range, block);
    HACQuadTreeGatherDataInRange(node->southWest, range, block);
    HACQuadTreeGatherDataInRange(node->southEast, range, block);
}

void HACQuadTreeTraverse(HACQuadTreeNode* node, HACQuadTreeTraverseBlock block)
{
    block(node);
    
    if (node->northWest == NULL) {
        return;
    }
    
    HACQuadTreeTraverse(node->northWest, block);
    HACQuadTreeTraverse(node->northEast, block);
    HACQuadTreeTraverse(node->southWest, block);
    HACQuadTreeTraverse(node->southEast, block);
}

HACQuadTreeNode* HACQuadTreeBuildWithData(HACQuadTreeNodeData *data, int count, HACBoundingBox boundingBox, int capacity)
{
    HACQuadTreeNode* root = HACQuadTreeNodeMake(boundingBox, capacity);
    for (int i = 0; i < count; i++) {
        HACQuadTreeNodeInsertData(root, data[i]);
    }
    
    return root;
}

void HACFreeQuadTreeNode(HACQuadTreeNode* node)
{
    if (node->northWest != NULL) HACFreeQuadTreeNode(node->northWest);
    if (node->northEast != NULL) HACFreeQuadTreeNode(node->northEast);
    if (node->southWest != NULL) HACFreeQuadTreeNode(node->southWest);
    if (node->southEast != NULL) HACFreeQuadTreeNode(node->southEast);
    
    for (int i=0; i < node->count; i++) {
        free(node->points[i].data);
    }
    free(node->points);
    free(node);
}

