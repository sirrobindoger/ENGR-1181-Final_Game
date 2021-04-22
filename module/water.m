classdef water < entity
    properties(SetAccess = public)
        world;
        material;
        color;
        gridPos;
        team;
        teammesh;
        hitmesh;
        hit;
    end
    properties (Constant)
        MAT_WATER = [0, 60, 60, 0, 0; 
                     0, 0, 60, 60, 0]
        MAT_TEAM = [0, 50, 50, 0, 0; 
                     0, 0, 50, 50, 0]
        MAT_HIT = [0,64
                   0,64]
    end
    methods
        function self = water(mat, world, pos, color)
            self.Type = entity.TYPE_WATER;
            self.world = world;
            self.material = mat;
            self.pos = pos;
            self.color = color;
            self.CollisionHull = 64; 
            self.team = 0;
            self.teammesh = plot(NaN, NaN, "-w");
            self.hit = false;
            self.hitmesh = plot(NaN, NaN, "-w");
            newPos = [self.material(1, :) + self.pos(1);...
                self.material(2, :) + self.pos(2)];
            set(self.Model, "XData", newPos(1, :), "YData", newPos(2, :), "Color", self.color, "LineWidth", 2);
        end
        function setTeam(self,num)
            if num == 1
                newPos = [self.MAT_TEAM(1, :) + self.pos(1)+5;...
                    self.MAT_TEAM(2, :) + self.pos(2)+5];
                
                set(self.teammesh, "XData", newPos(1, :), "YData", newPos(2, :), "Color", "green", "LineWidth", 2);
            elseif num == 2
               self.team = 2;
            end
        end
        function setHit(self)
            self.hit = true;
             newPos = [self.MAT_HIT(1, :) + self.pos(1)+5;...
                self.MAT_HIT(2, :) + self.pos(2)+5];

            set(self.hitmesh, "XData", newPos(1, :), "YData", newPos(2, :), "Color", "red", "LineWidth", 2);           
        end
    end
end
