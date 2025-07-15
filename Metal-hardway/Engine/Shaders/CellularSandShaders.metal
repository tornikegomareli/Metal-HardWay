//
//  CellularSandShaders.metal
//  Metal-hardway
//
//  Created by Tornike Gomareli on 14.01.25.
//

#include <metal_stdlib>
using namespace metal;

struct Cell {
  float type;
  float4 color;
};

struct CellularSandUniforms {
  int gridWidth;
  int gridHeight;
  float time;
  float2 mousePosition;
  float isMouseDown;
  float brushSize;
  int frameCounter;
};

struct VertexOut {
  float4 position [[position]];
  float4 color;
};

// Simple random function
float rand(float2 co) {
  return fract(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
}

vertex VertexOut cellularSandVertexShader(
  uint vertexID [[vertex_id]],
  uint instanceID [[instance_id]],
  const device Cell *grid [[buffer(0)]],
  constant CellularSandUniforms &uniforms [[buffer(1)]]
) {
  VertexOut out;
  
  // Calculate grid position from instance ID
  int x = instanceID % uniforms.gridWidth;
  int y = instanceID / uniforms.gridWidth;
  
  Cell cell = grid[instanceID];
  
  if (cell.type > 0) {
    const float2 quadVertices[] = {
      float2(0, 0), float2(1, 0), float2(0, 1),
      float2(1, 0), float2(1, 1), float2(0, 1)
    };
    
    float2 v = quadVertices[vertexID];
    
    float cellSize = 2.0;
    float2 cellPos = float2(x, y) * cellSize;
    float2 screenPos = cellPos + v * cellSize;
    
    float2 screenSize = float2(uniforms.gridWidth * cellSize, uniforms.gridHeight * cellSize);
    float2 normalizedPos = (screenPos / screenSize) * 2.0 - 1.0;
    normalizedPos.y = -normalizedPos.y;
    
    out.position = float4(normalizedPos, 0.0, 1.0);
    out.color = cell.color;
  } else {
    out.position = float4(0, 0, 0, 0);
    out.color = float4(0, 0, 0, 0);
  }
  
  return out;
}

fragment float4 cellularSandFragmentShader(VertexOut in [[stage_in]]) {
  return in.color;
}

kernel void cellularSandCompute(
  const device Cell *currentGrid [[buffer(0)]],
  device Cell *nextGrid [[buffer(1)]],
  constant CellularSandUniforms &uniforms [[buffer(2)]],
  uint2 gid [[thread_position_in_grid]]
) {
  int x = gid.x;
  int y = gid.y;
  
  if (x >= uniforms.gridWidth || y >= uniforms.gridHeight) return;
  
  int index = y * uniforms.gridWidth + x;
  Cell current = currentGrid[index];
  
  nextGrid[index] = current;
  
  if (y > 0 && current.type == 0) {
    int aboveIndex = (y - 1) * uniforms.gridWidth + x;
    Cell above = currentGrid[aboveIndex];
    
    if (above.type == 1) {
      nextGrid[index] = above;
      return;
    }
    
    if (x > 0) {
      int aboveLeftIndex = (y - 1) * uniforms.gridWidth + (x - 1);
      Cell aboveLeft = currentGrid[aboveLeftIndex];
      if (aboveLeft.type == 1) {
        if (y < uniforms.gridHeight - 1) {
          int belowLeftIndex = y * uniforms.gridWidth + (x - 1);
          Cell belowLeft = currentGrid[belowLeftIndex];
          if (belowLeft.type != 0) {
            nextGrid[index] = aboveLeft;
            return;
          }
        }
      }
    }
    
    if (x < uniforms.gridWidth - 1) {
      int aboveRightIndex = (y - 1) * uniforms.gridWidth + (x + 1);
      Cell aboveRight = currentGrid[aboveRightIndex];
      if (aboveRight.type == 1) {
        if (y < uniforms.gridHeight - 1) {
          int belowRightIndex = y * uniforms.gridWidth + (x + 1);
          Cell belowRight = currentGrid[belowRightIndex];
          if (belowRight.type != 0) {
            nextGrid[index] = aboveRight;
            return;
          }
        }
      }
    }
  }
  
  if (current.type == 1 && y < uniforms.gridHeight - 1) {
    int belowIndex = (y + 1) * uniforms.gridWidth + x;
    Cell below = currentGrid[belowIndex];
    
    bool moved = false;
    
    if (below.type == 0) {
      nextGrid[index] = Cell{0, float4(0)};
      moved = true;
    } else {
      bool canFallLeft = false;
      bool canFallRight = false;
      
      if (x > 0) {
        int belowLeftIndex = (y + 1) * uniforms.gridWidth + (x - 1);
        Cell belowLeft = currentGrid[belowLeftIndex];
        canFallLeft = (belowLeft.type == 0);
      }
      
      if (x < uniforms.gridWidth - 1) {
        int belowRightIndex = (y + 1) * uniforms.gridWidth + (x + 1);
        Cell belowRight = currentGrid[belowRightIndex];
        canFallRight = (belowRight.type == 0);
      }
      
      if (canFallLeft || canFallRight) {
        nextGrid[index] = Cell{0, float4(0)};
        moved = true;
      }
    }
  }
}
