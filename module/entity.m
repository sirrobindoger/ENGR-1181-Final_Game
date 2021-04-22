classdef entity < matlab.mixin.Heterogeneous & handle
    properties (SetAccess = public)
        % Properties
        Type;
        Mesh;
        Model;
        %Anims;
        %World Values
        gc;
        pos;
        Velocity;
        Angle;
        CollisionHull;      
    end
    properties(Constant)
        TYPE_NULL = 0;
        TYPE_PLAYER = 1;
        TYPE_PROP = 2;
        TYPE_NPC = 3
        TYPE_WATER = 4;
    end
    methods
        function self = entity()
            self.Type = entity.TYPE_NULL;   
            self.pos = [0;0];
            self.Velocity = [0;0];
            self.gc = false;
            self.Angle = 0;
            self.CollisionHull = 1;
            self.Mesh = []; 
            self.Model = plot(NaN, NaN, "-w");
        end
        function Destroy(self)
            delete(self.Model);
        end
        function Update(self, HEIGHT, WIDTH)
            % pass
        end
        function res = ShouldCollide(self, ent)
            res = true;
        end
    end
end


