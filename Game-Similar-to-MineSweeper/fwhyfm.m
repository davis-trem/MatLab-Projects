% fwhyfm.m
% 
% Author: Tremaine Davis
% Account: tdavis119
% CSc 4630/6630 Final Project
%
% Due date: 11-29-16
%
% Description: 
% Grid of buttons, when clicked, display amount of distance away
% from father.
%
% Input:
% Integer from 3 to 15
%
% Output:
% Winner or Loser
%
% Usage:
% fwhyfm(4)
% 

function fwhyfm(numOfRnC)

    % check for outrageous inputs
    if(numOfRnC < 3 || numOfRnC > 15)
        error('Come on son, you wildn. Use Integer between 3 and 15')
    end

    % Initialize/Create frame
    fWidth = (numOfRnC * 50)+ 100;
    fHieght = numOfRnC * 50;
    f = figure('Name','Father Why Have You Forsaken Me', ...
        'NumberTitle','off', 'Position',[200,200,fWidth,fHieght], ...
        'Resize','off');
    isWinner = false;
    
    % Array used for values of Button
    buttonValue(numOfRnC,numOfRnC) = 0;
    
    % Intialize Points
    score = '100';
    decPoints = ceil( 100/floor((numOfRnC*numOfRnC)/2) );
    
    % Menu Buttons
    bNew = uicontrol(f,'Style','pushbutton','String','NEW',...
                'Position',[fWidth-80, fHieght-50, 70, 50],...
                'Callback',{@bNewPressed});
    textScore = uicontrol(f,'Style','text','String',score,...
                'Position',[fWidth-80, fHieght-110, 70, 50]);
    textReslt = uicontrol(f,'Style','text','String','Good Luck on Your Search',...
                'Position',[fWidth-80, fHieght-140, 70, 50]);
    
    % Create Grid of Buttons
    for i = 1:numOfRnC
        for j = 1:numOfRnC
            button(i,j) = uicontrol(f, 'Style', 'Pushbutton', 'Units',...
                'pixels','Position', [(j-1)*50, (i-1)*50, 50, 50], 'Callback',{@buttonPressed,i,j});
        end
    end
    
    %Initialize Father Location
    fatherLoc = randi([1, numOfRnC], 1,2);
    buttonValue(fatherLoc(1),fatherLoc(2)) = 2;
    
    function bNewPressed(src,event)
        isWinner = false;
        % Array used for values of Button all set to 0
        buttonValue(:,:) = 0;
        
        % empty 3d array for pic
        blankimage = ones(1,1,1);
        blankimage(:,:,3) = 1;
        
        % Reset buttons
        for a = 1:numOfRnC
            for b = 1:numOfRnC
                set(button(a,b), 'string','', 'enable','on', 'cdata',blankimage);
            end
        end
        
        % Reset Score
        score = '100';
        set(textScore, 'String',score)
        % Reset Text
        set(textReslt, 'String',{'Good Luck on Your Search'});
        
        %Initialize Father Location
        fatherLoc = randi([1, numOfRnC], 1,2);
        buttonValue(fatherLoc(1),fatherLoc(2)) = 2;
    end
    
    function buttonPressed(src,event,i,j)
       %display(sprintf('%d,%d Button pressed',i,j));
       
       
       if(i == fatherLoc(1) && j == fatherLoc(2))
           winner(i,j)
       else
           % button labeled as clicked
           buttonValue(i,j) = 1;
           % decrease score
           score = num2str( str2num(score)-decPoints );
           set(textScore, 'String',score)
           moveFather()
           
           % check for lost
           if(isWinner==false && str2num(score) < 1)
               set(textScore, 'String','0')
               loser()
           end
       end
              
       calcDistance();
    end %function buttonPressed

    function calcDistance()
        for brow=1:numOfRnC
            for bcol=1:numOfRnC
                if(buttonValue(brow,bcol)==1)
                    distance = ((fatherLoc(1)-brow)^2)+((fatherLoc(2)-bcol)^2);
                    distance = floor(sqrt(distance));
                    set(button(brow,bcol),'string',distance,'enable','off');
                end
            end
        end
    end %calcDistance

    function moveFather()
        %father is no longer in this location
        buttonValue(fatherLoc(1),fatherLoc(2)) = 0; 
        
        valid = 0;
        rollResult = [];
        while (~valid)
            rollDie = randi([1, 8], 1);
            %check if rollDie# has already been use
            if(any(rollResult(:) == rollDie))
                if(length(rollResult) == 8)
                    disp('CANNOT MAKE ANY MOVES')
                    num = (str2num(score)+decPoints)*2;
                    disp(num)
                    score = num2str( num );
                    set(textScore, 'String',score)
                    winner(fatherLoc(1),fatherLoc(2))
                    % extra points for capture
                    break;
                end
                
                valid = 0;
            else
                switch(rollDie)
                    case 1
                        % fatherRow -1 [up]
                        if((fatherLoc(1)-1) < 1 || buttonValue(fatherLoc(1)-1,fatherLoc(2)))
                            rollResult(end+1) = rollDie;
                            valid = 0;
                        else
                            fatherLoc(1) = fatherLoc(1) - 1;
                            valid = 1;
                        end

                    case 2
                        % fatherRow +1 [down]
                        if((fatherLoc(1)+1) > numOfRnC || buttonValue(fatherLoc(1)+1,fatherLoc(2)))
                            rollResult(end+1) = rollDie;
                            valid = 0;
                        else
                            fatherLoc(1) = fatherLoc(1) + 1;
                            valid = 1;
                        end

                    case 3
                        % fatherCol -1 [left]
                        if((fatherLoc(2)-1) < 1 || buttonValue(fatherLoc(1),fatherLoc(2)-1))
                            rollResult(end+1) = rollDie;
                            valid = 0;
                        else
                            fatherLoc(2) = fatherLoc(2) - 1;
                            valid = 1;
                        end

                    case 4
                        % fatherCol +1 [right]
                        if((fatherLoc(2)+1) > numOfRnC || buttonValue(fatherLoc(1),fatherLoc(2)+1))
                            rollResult(end+1) = rollDie;
                            valid = 0;
                        else
                            fatherLoc(2) = fatherLoc(2) + 1;
                            valid = 1;
                        end

                    case 5
                        % fatherRownCol -1 [diagonal up left]
                        if((fatherLoc(1)-1) < 1 || (fatherLoc(2)-1) < 1 || buttonValue(fatherLoc(1)-1,fatherLoc(2)-1))
                            rollResult(end+1) = rollDie;
                            valid = 0;
                        else
                            fatherLoc = fatherLoc - 1;
                            valid = 1;
                        end

                    case 6
                        % fatherRownCol +1 [diagonal down right]
                        if((fatherLoc(1)+1) > numOfRnC || (fatherLoc(2)+1) > numOfRnC || buttonValue(fatherLoc(1)+1,fatherLoc(2)+1))
                            rollResult(end+1) = rollDie;
                            valid = 0;
                        else
                            fatherLoc = fatherLoc + 1;
                            valid = 1;
                        end
                    case 7
                        % fatherRow -1 fatherCol +1 [diagonal up right]
                        if((fatherLoc(1)-1) < 1 || (fatherLoc(2)+1) > numOfRnC || buttonValue(fatherLoc(1)-1,fatherLoc(2)+1))
                            rollResult(end+1) = rollDie;
                            valid = 0;
                        else
                            fatherLoc(1) = fatherLoc(1) - 1;
                            fatherLoc(2) = fatherLoc(2) + 1;
                            valid = 1;
                        end

                    case 8
                        % fatherRow +1 fatherCol -1 [diagonal down left]
                        if((fatherLoc(1)+1) > numOfRnC || (fatherLoc(2)-1) < 1 || buttonValue(fatherLoc(1)+1,fatherLoc(2)-1))
                            rollResult(end+1) = rollDie;
                            valid = 0;
                        else
                            fatherLoc(1) = fatherLoc(1) + 1;
                            fatherLoc(2) = fatherLoc(2) - 1;
                            valid = 1;
                        end
                end %switch
            end %if
        end %while
        buttonValue(fatherLoc(1),fatherLoc(2)) = 2;
        %disp(buttonValue)
    end %moveFather

    function winner(f1,f2)
        disp('WINNER!')
        isWinner = true;
        x = imread('father.png');
        set(button(f1,f2), 'cdata',x);
        for brow=1:numOfRnC
            for bcol=1:numOfRnC
                 if(brow ~= fatherLoc(1) || bcol ~= fatherLoc(2))
                     set(button(brow,bcol),'enable','off');
                 end
            end
        end
        set(textReslt, 'String',{'CONGRATULATIONS','YOU FOUND HIM!!'});
    end %winner

    function loser()
        disp('LOSER!')
        for brow=1:numOfRnC
            for bcol=1:numOfRnC
                 set(button(brow,bcol),'enable','off');
            end
        end
        set(textReslt, 'String',{'FAILURE!!','NO WONDER HE LEFT YOU'});
    end %loser

end %function fwhyfm

