function compareXLS()
    % Initialize/Create frame
    f = figure('Name','Compare XLS', 'NumberTitle','off', 'Position',[200,200,640,360]);
    
    % Initialize Global Variables
    userInput = [];
    file1 = [];
    file2 = [];
    colList = [];
    clCount = 1;
    % Hold rows the Main match
    mainMatches = [];
    % Hold amount of Main matches
    mMcount = 0;
    % Hold rows the Full match
    fullMatches = {};
    % Hold amount of Full matches
    fMcount = 1;
    % Hold rows the No match
    noMatches = {};
    % Hold amount of No matches
    noMcount = 1;
    % Hold rows the almost match
    almostMatches = {};
    % Hold amount of almost matches
    almostMcount = 1;
    
    % Create Buttons
    bGetFiles = uicontrol(f, 'Style', 'Pushbutton', 'Units','pixels',...
    	'Position', [10, 320, 60, 25],'String','Get Files',...
        'Callback',{@bGetFilesPressed});
    
    bCompare = uicontrol(f, 'Style', 'Pushbutton', 'Units','pixels',...
    	'Position', [80, 320, 80, 25], 'String','Compare Files' ,...
        'Callback',{@bComparePressed}, 'enable','off');
    
    bSave = uicontrol(f, 'Style', 'Pushbutton', 'Units','pixels',...
    	'Position', [170, 320, 60, 25], 'String','Save' ,...
        'Callback',{@bSavePressed}, 'enable','off');
                
    bAddMore = uicontrol(f, 'Style','Pushbutton', 'Units','pixels',...
    	'Position', [370, 290, 80, 25], 'String','Add More',...
        'Callback',{@bAddMorePressed}, 'visible','off');
    
    bRemove = uicontrol(f, 'Style','Pushbutton', 'Units','pixels',...
    	'Position', [450, 290, 80, 25], 'String','Remove',...
        'Callback',{@bRemovePressed}, 'visible','off');

    cbIsMain(clCount) = uicontrol(f, 'Style','checkbox',...
        'String','Main Column', 'Value',1,...
        'Position',[290, 290, 80, 25], 'visible','off');
    
    phoneNum(clCount) = uicontrol(f, 'Style','checkbox',...
        'String','Phone#', 'Value',0,...
        'Position',[530, 290, 80, 25], 'visible','off');
    
            
    function bGetFilesPressed(src,event)
        % Create/Display Popup
        userInput = inputdlg({'Enter Path of First file','Enter Path of Second file'},...
            'Files'' Path', [1 50; 1 50], {'ex. C:\Users\Trey\Documents\file.xls',''});
        
        % Fill both lines to enable Compare Button
        if(~strcmp(userInput(1),'') && ~strcmp(userInput(2),''))
            set(bCompare, 'enable','on');
        end
        
        % Get files from specifiled path
        [~,~,file1] = xlsread(userInput{1});
        [~,~,file2] = xlsread(userInput{2});
        
        % Creates Dropdown List of xls' columns and Add More button
        colList(clCount,1) = uicontrol(f,'Style','popupmenu',...
            'String',file1(1,:), 'Value',1,'Position',[10 290 130 25]);
    
        colList(clCount,2) = uicontrol(f,'Style','popupmenu',...
            'String',file2(1,:), 'Value',1,'Position',[150 290 130 25]);
        
        set(cbIsMain(clCount), 'visible','on');
        set(phoneNum(clCount), 'visible','on');
        set(bAddMore, 'visible','on');
        
    end %bGetFilesPressed

    function bComparePressed(src,event)
        % Handles Phone #
        convertPhoneNum();
        
           
        file1MCol = [];
        file2MCol = [];
        file1SCol = [];
        file2SCol = [];
        % Get dropdown values of column selected to be MainColumns
        for i=1:length(getMainCol())
            mainCol = getMainCol();
            
            file1MCol(i) = get(colList(mainCol(i),1),'Value');
            file2MCol(i) = get(colList(mainCol(i),2),'Value');
        end
        
        % Get dropdown values of column selected to be SubColumns
        for i=1:length(getSubCol())
            subCol = getSubCol();
            
            file1SCol(i) = get(colList(subCol(i),1),'Value');
            file2SCol(i) = get(colList(subCol(i),2),'Value');
        end
        
        % Add column Titles to Full Match array
        fullMatches(fMcount,1:2) = {'File 1 Row','File 2 Row'};
        fullMatches(fMcount,3:2+length(file1MCol)) = file1(1,file1MCol);
        fullMatches(fMcount,3+length(file1MCol):2+length(file1MCol)+length(file1SCol)) = file1(1,file1SCol);
        
        % Add column Titles to Almost Match array
        almostMatches(almostMcount,1:2) = {'File 1 Row','File 2 Row'};
        almostMatches(almostMcount,3:2+length(file1SCol)) = file1(1,file1SCol);
        
        % Add column Titles to No Match array
        noMatches(noMcount,1:2) = {'File','Row'};
        noMatches(noMcount,3:2+length(file1MCol)) = file1(1,file1MCol);
        noMatches(noMcount,3+length(file1MCol):2+length(file1MCol)+length(file1SCol)) = file1(1,file1SCol);
        
        for i=2:length(file1(:,1))
            for j=2:length(file2(:,1))
                % Check if File1 main column are equal to File2 main column
                if(strcmp(file1(i,file1MCol),file2(j,file2MCol)))
                    mMcount = mMcount + 1;
                    mainMatches(mMcount,1) = i;
                    mainMatches(mMcount,2) = j;
%                     disp('---Matches---')
%                     fprintf('row %d and row %d',i,j)
%                     disp(file1(i,file1MCol))
%                     disp(file2(j,file2MCol))
                    
                    if(~isempty(file1SCol)) % If there are Sub columns
                        if(strcmp(file1(i,file1SCol),file2(j,file2SCol)))
                            fMcount = fMcount + 1;
                            fullMatches(fMcount,1) = {num2str(i)};
                            fullMatches(fMcount,2) = {num2str(j)};
                            fullMatches(fMcount,3:2+length(file1MCol)) = file1(i,file1MCol);
                            fullMatches(fMcount,3+length(file1MCol):2+length(file1MCol)+length(file1SCol)) = file1(i,file1SCol);
                        else
                            % Finds file1SCol array index for column# of file element that does not match
                            index = find(~strcmp(file1(i,file1SCol),file2(j,file2SCol)));
                            
                            almostMcount = almostMcount + 1;
                            % File 1 row
                            almostMatches(almostMcount,1) = {num2str(i)};
                            for k=1:length(index)
                                locate = index(k);
                                almostMatches(almostMcount,2+locate) = file1(i,file1SCol(locate));
                            end
                            
                            almostMcount = almostMcount + 1;
                            % File 2 row
                            almostMatches(almostMcount,2) = {num2str(j)};
                            for k=1:length(index)
                                locate = index(k);
                                almostMatches(almostMcount,2+locate) = file2(i,file2SCol(locate));
                            end
                            
                            
                        end
                    else
                        fMcount = fMcount + 1;
                        fullMatches(fMcount,1) = {num2str(i)};
                        fullMatches(fMcount,2) = {num2str(j)};
                        fullMatches(fMcount,3:2+length(file1MCol)) = file1(i,file1MCol);
                        fullMatches(fMcount,3+length(file1MCol):2+length(file1MCol)+length(file1SCol)) = file1(i,file1SCol);
                    end
                end
            end
        end
        
        if(~isempty(mainMatches))
            % Find rows that did not match in File 1
            for i=2:length(file1(:,1))
                if(~any(i == mainMatches(:,1)))
                    noMcount = noMcount + 1;
                    noMatches(noMcount,1) = {'File1'};
                    noMatches(noMcount,2) = {num2str(i)};
                    noMatches(noMcount,3:2+length(file1MCol)) = file1(i,file1MCol);
                    noMatches(noMcount,3+length(file1MCol):2+length(file1MCol)+length(file1SCol)) = file1(i,file1SCol);
                end
            end

            % Find rows that did not match in File 2
            for i=2:length(file2(:,1))
                if(~any(i == mainMatches(:,2)))
                    noMcount = noMcount + 1;
                    noMatches(noMcount,1) = {'File2'};
                    noMatches(noMcount,2) = {num2str(i)};
                    noMatches(noMcount,3:2+length(file1MCol)) = file2(i,file2MCol);
                    noMatches(noMcount,3+length(file1MCol):2+length(file1MCol)+length(file1SCol)) = file2(i,file2SCol);
                end
            end
        end
        
        set(bSave,'enable','on');
    end %bComparePressed

    function bAddMorePressed(src,event)
        clCount = clCount + 1;
        % Creates Dropdown List of xls' columns and Add More button
        colList(clCount,1) = uicontrol(f,'Style','popupmenu',...
            'String',file1(1,:), 'Value',1,'Position',[10, 290-(25*(clCount-1)), 130, 25]);
    
        colList(clCount,2) = uicontrol(f,'Style','popupmenu',...
            'String',file2(1,:), 'Value',1,'Position',[150, 290-(25*(clCount-1)), 130, 25]);
        
        % Creates check box
        cbIsMain(clCount) = uicontrol(f, 'Style','checkbox',...
        'String','Main Column', 'Value',0,...
        'Position',[290, 290-(25*(clCount-1)), 80, 25]);
    
        phoneNum(clCount) = uicontrol(f, 'Style','checkbox',...
        'String','Phone#', 'Value',0,...
        'Position',[530, 290-(25*(clCount-1)), 80, 25]);
        
        % Moves Add and Remove Button
        set(bAddMore, 'Position', [370, 290-(25*(clCount-1)), 80, 25]);
        set(bRemove, 'Position', [450, 290-(25*(clCount-1)), 80, 25], 'visible','on');
        
    end %bAddMorePressed

    function bRemovePressed(src,event)
        % Hide/remove Dropdown list
        set(colList(clCount,1), 'visible','off');
        set(colList(clCount,2), 'visible','off');
        colList(clCount,1) = 0;
        colList(clCount,2) = 0;
        
        % Hide/remove check box
        set(cbIsMain(clCount), 'visible','off');
        cbIsMain(clCount) = 0;
        
        set(phoneNum(clCount), 'visible','off');
        phoneNum(clCount) = 0;
        
        % Move Add More and Remove up to previous Dropdown
        clCount = clCount - 1;
        set(bAddMore, 'Position', [370, 290-(25*(clCount-1)), 80, 25]);
        set(bRemove, 'Position', [450, 290-(25*(clCount-1)), 80, 25]);
        
    end %bRemovePressed

    function result = getMainCol()
        for i=1:clCount
            mainCol(i) = get(cbIsMain(i),'Value');
        end
        result = find(mainCol);
    end %getMainCol

    function result = getSubCol()
        for i=1:clCount
            subCol(i) = get(cbIsMain(i),'Value');
        end
        result = find(~subCol);
    end %getSubCol

    function result = getLargerCol()
        larger = 0;
        for i=1:length(getMainCol())
            col1 = get(colList(i,1),'Value');
            tempfile1 = file1(:,col1);
            
            col2 = get(colList(i,2),'Value');
            tempfile2 = file2(:,col2);
            
            if(size(tempfile1,1) >= size(tempfile2,1) && size(tempfile1,1) >= larger)
                larger = size(tempfile1,1);
            elseif(size(tempfile2,1) >= size(tempfile1,1) && size(tempfile2,1) >= larger)
                larger = size(tempfile2,1);
            end
        end
        result = larger;
    end %getLargerCol

    function convertPhoneNum()
        % Gets all of the phone# checkboxes values
        for i=1:clCount
            phoneCol(i) = get(phoneNum(i),'Value');
        end
        % Stores only the checkboxes the are checked
        phoneCol = find(phoneCol);
        
        for i=1:length(phoneCol)
            % FILE 1
            % Gets column to convert
            colPos1 = get(colList(phoneCol(i),1), 'Value');
            file1Col = file1(2:end,colPos1);
            for j=1:length(file1Col)
                % Check if its NaN
                if(length(file1Col{j}) > 1)
                    remove = ismember(file1Col{j},'-')+ismember(file1Col{j},'(')+...
                        ismember(file1Col{j},')')+ismember(file1Col{j},' ');
                    temp = file1Col{j};
                    temp = temp(find(~remove));
                    % Save only the digits seperated by hyphens
                    file1Col{j} = strcat(temp(1:3),'-',temp(4:6),'-',temp(7:10));
                end
            end
            file1(2:end,colPos1) = file1Col;
            
            %FILE 2
            % Gets column to convert
            colPos2 = get(colList(phoneCol(i),2), 'Value');
            file2Col = file2(2:end,colPos2);
            for j=1:length(file2Col)
                % Check if its NaN
                if(length(file2Col{j}) > 1)
                    % gathers indeces that doesnt contain numbers
                    remove = ismember(file2Col{j},'-')+ismember(file2Col{j},'(')+...
                        ismember(file2Col{j},')')+ismember(file2Col{j},' ');
                    temp = file2Col{j};
                    temp = temp(find(~remove));
                    % Save only the digits seperated by hyphens
                    file2Col{j} = strcat(temp(1:3),'-',temp(4:6),'-',temp(7:10));
                end
            end
            file2(2:end,colPos2) = file2Col;
        end
    end %convertPhoneNum

    function bSavePressed(src,event)
       % Create/Display Popup
        saveInput = inputdlg({'Enter Path/Name of file to save'},...
            'Save File', [1 50], {'ex. C:\Users\Trey\Desktop\file.xls OR file.xls'});
        
        % Fill both lines to enable Compare Button
        if(~strcmp(saveInput(1),''))
            xlswrite(saveInput{1},fullMatches,'Full Matches');
            xlswrite(saveInput{1},almostMatches,'Differences');
            xlswrite(saveInput{1},noMatches,'No Matches');
            disp('Done')
            set(bSave,'String','Saved!')
%             disp(fullMatches)
%             disp(almostMatches)
%             disp(noMatches)
%             disp(mainMatches)
        end
    end

end %compareXLS