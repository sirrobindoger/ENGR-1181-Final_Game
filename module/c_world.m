% handles gamelogic and controls all entities
classdef c_world < handle
    properties (SetAccess = public)
        %keyboard
        Keys = [];
        Lookup = [];
        Lookup1 = [];
        %ents
        Player = []; % player entity
        Grid = {}; % list of active entities
        %window dimensions
        W;
        H;
        insertFloor;
        %input
        inputText = [];
        inputTextSub = [];
        targetInput = [];
        targetInput1 = [];
        % 1 is for x axis, 
        % 2 is for y axis
        % 3 is for hit/miss (anycontinue)
        % 4 is for enemy hit attempt (anycontinue)
        % 5 is if enemy hit -> 1 (anycontinue)
        inputState = 1; 
        currInputGrid = [];
        didHit = [];
        enemyTargeting = [];
        anyContinue = [];
        toggleContinue = false;
        enemyRemaining = 0;
        enemyRemainingText = [];
        enemyHit;
        %ships
        userShips = [];
        enemyShips = [];
    end
    methods
        function self = c_world(w, h, window)
            %%%%% INIT VARIABLES
            self.Keys = containers.Map(...
                ["w","a","s","d","space"],...
                {false,false,false,false,false}...
            );
            self.Lookup = containers.Map(...
                ["a","b", "c", "d", "e","f","g","h","i","j", "k"],...
                {1,  2,    3,    4,  5,  6,  7,  8,  9,  10, 11}...
            );
            self.Lookup1 = containers.Map(...
                ["1", "2",    "3",    "4",  "5",  "6",  "7",  "8",  "9",  "10", "11"],...
                ["a","b", "c", "d", "e","f","g","h","i","j", "k"]...
            );
            self.W = w;
            self.H = h;
            i1 = 1;
            i2 = 1;
            %%INIT GRID
            for x=100:60:700
                for y=100:60:700
                    if y == 100
                        text( 60, i1*60+70, num2str(i1), ...
                       'FontSize', 30, 'Color', 'w', 'HorizontalAlignment', 'Center' );
                    end
                    newWater = water(water.MAT_WATER, self, [x;y], "#4287f5");
                    newWater.gridPos = [i1;i2];
                    self.Grid = [self.Grid,newWater];
                    i2 = i2 + 1;
                end
                text( x+30, 100-20, upper(self.Lookup1(num2str(i1)) ), ...
            'FontSize', 30, 'Color', 'w', 'HorizontalAlignment', 'Center' );
                i1 = i1 + 1;
                i2 = 1;
            end
            %%INIT TEXT
            set(window, "KeyPressFcn", @self.keyDown);
            text(770, 750, "BATTLESHIP", "FontSize", 35, "Color", "#4287f5");
            self.inputState = 1;
          
            self.inputText = text(770, 700, "Enter Letter [a-k]:", "FontSize", 25, "Color", "#4287f5");
            self.inputTextSub = text(930, 700, "", "FontSize", 25, "Color", "#4287f5");
            text(770, 650, "Your target:", "FontSize", 25, "Color", "#4287f5");
            self.targetInput = text(910, 650, "", "FontSize", 25, "Color", "#4287f5");
            self.targetInput1 = text(940, 650, "", "FontSize", 25, "Color", "#4287f5");
            self.anyContinue = text(770, 500, "", "FontSize", 15, "Color", "#4287f5");
            self.didHit = text(770, 600, "", "FontSize", 25, "Color", "yellow");
            self.enemyTargeting = text(770, 550, "", "FontSize", 25, "Color", "#4287f5");
            self.enemyHit = text(770, 525, "", "FontSize", 25, "Color", "#4287f5");
            self.enemyRemainingText = text(770, 400, "Enemies Remaning: ", "FontSize", 20, "Color", "red");
            %%INIT SHIPS
            self.userShips = self.generateShip(2, 10)
            self.enemyShips = self.generateShip(2, 10);
            for i = 1:self.userShips
                cShipPos = self.userShips(i,:);
                for ent = self.Grid
                    if ent.gridPos(1) == cShipPos(1) && ent.gridPos(2) == cShipPos(2)
                        ent.setTeam(1);
                    end
                end
            end
            
            for i = 1:self.enemyShips
                cShipPos = self.enemyShips(i,:);
                for ent = self.Grid
                    if ent.gridPos(1) == cShipPos(1) && ent.gridPos(2) == cShipPos(2) && ent.team ~= 2
                        ent.setTeam(2);
                    end
                end
            end
            self.enemyShips
            self.countEnemy()
        end
        %%NEW KEY DOWN%%%%%%%%%%%%%%%%%
        function keyDown(self, ~, event)
            switch self.inputState
                case 1%
                    set(self.enemyHit,"String", "");
                    set(self.enemyTargeting, "String", "");
                    set(self.didHit,"String", "");
                    set(self.anyContinue ,"String", "");
                    if self.Lookup.isKey(lower(event.Key))
                        self.currInputGrid = [ self.Lookup(lower(event.Key)) ];
                        self.inputState = 2;
                        self.toggleContinue = false;
                        set(self.inputText,"String","Enter number [1-11]:")
                    end
                case 2
                    if self.Lookup1.isKey(event.Key)
                        self.currInputGrid = [self.currInputGrid, str2num(lower(event.Key))];
                        waterB = self.getWaterBlock(self.currInputGrid);
                        set(self.inputText,"String", "");
                        if waterB.team == 2
                            set(self.didHit,"String", "Hit!", "Color", "red");
                            waterB.setHit();

                            self.countEnemy();
                        else
                            set(self.didHit,"String", "Miss!", "Color", "yellow");
                        end
                        self.inputState = 3;
                        set(self.anyContinue ,"String", "Press any key to continue");
                    end  
                case 3
                    set(self.didHit,"String", "", "Color", "yellow");
                    set(self.enemyTargeting, "String", "Enemy is now firing...");
                    self.inputState = 4;
                case 4
                    enemyBlock = self.getWaterBlock([self.randomNum(1,11), self.randomNum(1,11)]);
                    if enemyBlock.team == 2
                        set(self.enemyHit,"String", "Hit!", "Color", "red");
                    else
                        set(self.enemyHit,"String", "Miss!", "Color", "yellow");
                    end
                    set(self.inputText,"String","Enter Letter [a-k]")
                    self.inputState = 1;
            end
        end

        %%RAN NUM FUNCTION
        function num = randomNum(~, a,b)
            num = round( a + (b-a) .* rand(1,1) );
        end
        %%countenemy
        function countEnemy(self)
            i = 0;
            for ent = self.Grid
                if ent.team == 2 && ~ent.hit
                    ent.hit
                    i = i + 1;
                end
            end
            set(self.enemyRemainingText, "String", strcat("Enemies Remaining: ", num2str(i)));
        end
        %%GENERATE SHIP FUNCTION
        function shipPos = generateShip(self,size, count)
            shipPos = [];
            shipCenters = [];
            %plot ships
            for i = 1:count
                shipCenters = [shipCenters; self.randomNum(1,11), self.randomNum(1,11)];
            end
            %set out ships
            for i = 1:length(shipCenters)
                currShip = shipCenters(i, :);  
                %if horizontal == 2
                    if size == 2
                        newShip = [...
                          currShip(1)-1, currShip(2);...
                          currShip(1), currShip(2);...
                          currShip(1)+1, currShip(2)];
                      shipPos = [shipPos; newShip];
                    end
                %end
            end
        end
        %%GET WATER BLOCK FUNCTION
        function water = getWaterBlock(self,pos)
            for ent = self.Grid
                if  ent.gridPos(1) == pos(1) && ent.gridPos(2) == pos(2)
                    water = ent;
                end
            end
        end
        %%UPDATE
        function Update(self, ~,~)
            if length(self.currInputGrid) == 1
                set(self.targetInput, "String", upper( self.Lookup1(num2str(self.currInputGrid(1)))) );
            end
            if length(self.currInputGrid) == 2
                set(self.targetInput1, "String", num2str(self.currInputGrid(2)));
            end
            
        end
    end

end