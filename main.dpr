Program CoolGame;

Uses
    System.SysUtils, Classes, Windows, System.Generics.Collections;

Const
    CHOOSE_START_GAME = 0;
    CHOOSE_PRINT_TASK = 1;
    SPEECH_PARTS_NUM = 3;
    HINT_WORDS_NUM = 3;
    ATTEMPTS_NUM = 3;
    WIN_POINTS_NUM = 15;
    MAX_WORDS_NUM_IN_ROW = 10;
    PLAYERS_MIN_NUM = 2;
    PLAYERS_MAX_NUM = 5;
    SPEECH_PARTS_ARR:Array[1..SPEECH_PARTS_NUM*2] Of String = (
        ' прилагательных:',
        ' глагола:',
        ' существительных:',
        'Прилагательные:',
        'Глаголы:',
        'Существительные:'
    );

    START_DICTIONARY_OF_WORDS: Array[0..88] Of String = (
    'стол', 'стул', 'книга', 'ручка', 'компьютер',
    'телефон', 'окно', 'мяч', 'машина',
    'дом', 'сад', 'цветок', 'забор', 'печь',
    'чашка', 'тарелка', 'ложка', 'вилка', 'нож',
    'письмо', 'танк', 'город', 'парк', 'вода',
    'море', 'река', 'океан', 'воздух', 'мост',
    'города', 'страна', 'горы', 'яблоко', 'банан',
    'апельсин', 'груша', 'арбуз', 'вишня', 'слива',
    'мороженое', 'печенье', 'торт', 'суп', 'чай',
    'кофе', 'сок', 'яйцо', 'сыр', 'дверь',
    'хлеб', 'масло', 'мясо', 'рыба', 'овощи',
    'фрукты', 'молоко', 'сахар', 'соль', 'перец',
    'ананас', 'клубника', 'черника', 'малина',
    'футбол', 'баскетбол', 'зима', 'лето', 'осень', 'весна',
    'теннис', 'бег', 'плавание', 'велосипед', 'коньки',
    'гитара', 'пианино', 'скрипка', 'труба', 'барабан',
    'музыка', 'танец', 'театр', 'кино', 'картинка',
    'маляр', 'сказка', 'роман', 'поэма', 'видеоигра'
  );


Type
    TStrMatrix = Array  Of Array Of String;
    TPartOfSpeech = (TPS_NONE,TPS_ADJ,TPS_VERB,TPS_NOUN);
    TIntArr = Array Of Integer;

procedure ClearConsole;
var
    ConsoleHandle: THandle;
    ConsoleSize: DWORD;
    Written: DWORD;
    Coord: TCoord;
    ConsoleInfo: TConsoleScreenBufferInfo;
begin
    ConsoleHandle := GetStdHandle(STD_OUTPUT_HANDLE);
    if ConsoleHandle = INVALID_HANDLE_VALUE then
        Exit;
    if not GetConsoleScreenBufferInfo(ConsoleHandle, ConsoleInfo) then
        Exit;
    ConsoleSize := ConsoleInfo.dwSize.X * ConsoleInfo.dwSize.Y;
    Coord.X := 0;
    Coord.Y := 0;
    FillConsoleOutputCharacter(ConsoleHandle, ' ', ConsoleSize, Coord, Written);
    FillConsoleOutputAttribute(ConsoleHandle, ConsoleInfo.wAttributes, ConsoleSize, Coord, Written);
    SetConsoleCursorPosition(ConsoleHandle, Coord);
end;


Function CreatListOfWords(): TStringList;
Var
    I: Integer;
    WordDictonary: TStringList;

Begin
    WordDictonary := TStringList.Create;
    For I := 0 To High(START_DICTIONARY_OF_WORDS) Do
        WordDictonary.Add(START_DICTIONARY_OF_WORDS[I]);

    CreatListOfWords := WordDictonary;
End;


Procedure ChoiceOfSecretWords(Words: TStrMatrix;Var WordDictonary: TStringList; Var Secret_Words_Amounts: Integer);
Var
    I, PlayersAmount, RandomNum: Integer;

Begin
    PlayersAmount := High(Words);

    For I := 0 To PlayersAmount Do
    Begin
        Randomize;
        RandomNum := Random(Secret_Words_Amounts);
        Words[I][0] := WordDictonary[RandomNum];
        WordDictonary.Delete(RandomNum);
        Dec(Secret_Words_Amounts);
    End;
End;


Function EnterNumberOfPlayers(): Integer;
Var
    NumberOfPlayers: Integer;
    IsCorrect: Boolean;
Begin
    NumberOfPlayers := 0;
    Writeln('Введите количество игроков:');
    Repeat
        IsCorrect := True;
        Try
            Readln(NumberOfPlayers);
        Except
            IsCorrect := False;
            Writeln('Неверный ввод! Введите еще раз!');
        End;
        If IsCorrect And (NumberOfPlayers < PLAYERS_MIN_NUM) Or
          (NumberOfPlayers > PLAYERS_MAX_NUM) Then
        Begin
            IsCorrect := False;
            Writeln('Неподходящее количество игроков! Количество игроков должно быть от ', PLAYERS_MIN_NUM, ' до ', PLAYERS_MAX_NUM,'!');
        End;
    Until IsCorrect;
    EnterNumberOfPlayers := NumberOfPlayers;
End;


Procedure InputWords(Words: TStrMatrix; I,J : Integer);
Var
    Word: String;
Begin
    For Var K := 0 To HINT_WORDS_NUM - 1 Do
    Begin
        Readln(Word);
        LowerCase(Word);
        Words[I][K+J] := Word;
    End;
End;



Function GuessingSecreteWord(Const SecretWord:String):Boolean;
Var
    IsCorrect : Boolean;
    PlayerWord:String;
Begin
    IsCorrect := False;
    Writeln('Введите слово');
    Readln(PlayerWord);
    LowerCase(PlayerWord);
    If(PlayerWord = SecretWord) Then
    Begin
        IsCorrect:=True;
        Writeln('Вы угадали слово.');
    End
    Else
        WriteLn('Вы не угадали слово.');
    GuessingSecreteWord := IsCorrect;
End;


Procedure OutputAssociation(Const MatrixOfPlayersWords:TStrMatrix;Const ArrGue:TIntArr;Var ArrPoints:TIntArr);
Var
    J:Integer;
    PartOfSpeech:TPartOfSpeech;
    IsCorrect:Boolean;
Begin
    For Var I := 0 To High(ArrGue) Do
    Begin
        Writeln('Игрок', I + 1);
        J := 1;
        IsCorrect := False;
        PartOfSpeech := Low(TPartOfSpeech);
        While(Not IsCorrect) And (J <= High(MatrixOfPlayersWords[I])) Do
        Begin
            PartOfSpeech := Succ(PartOfSpeech);
            Writeln(SPEECH_PARTS_ARR[Ord(PartOfSpeech) + SPEECH_PARTS_NUM]);
            For Var K := 0 To HINT_WORDS_NUM-1 Do
                Writeln(MatrixOfPlayersWords[ArrGue[I]][J+K]);
            Inc(J,HINT_WORDS_NUM);
            IsCorrect := GuessingSecreteWord(MatrixOfPlayersWords[ArrGue[I]][0]);
        End;
        If IsCorrect Then
        Begin
            ArrPoints[I] := ArrPoints[I] + ATTEMPTS_NUM - J Div 3 + 1;
            Inc(ArrPoints[ArrGue[I]]);
        End
        Else
            Dec(ArrPoints[ArrGue[I]]);
        If I =  High(ArrGue) Then
            Writeln('Переход к результатам')
        Else
            Writeln('Переход к игроку ', I + 2);
        Readln;

        ClearConsole();
    End;
End;


Procedure InputAnything(PartOfSpeech:TPartOfSpeech; Words: TStrMatrix; I,J : Integer);
Begin
    Writeln('Введите ', HINT_WORDS_NUM, SPEECH_PARTS_ARR[Ord(PartOfSpeech)]);
    InputWords(Words,I,J);
    {Case PartOfSpeech Of
        TPS_ADJ:
        Begin
        End;
        TPS_VERB:
        Begin
        End;
        TPS_NOUN:
        Begin
        End;
    End;}

End;


Procedure InputData(MatrixOfPlayersWords: TStrMatrix; NumberOfPLayers: Integer);
Var
    I, J, K: Integer;
    PartOfSpeech: TPartOfSpeech;
    NumOfSecretWords: Integer;
    WordDictonary: TStringList;
Begin
    NumOfSecretWords := Length(START_DICTIONARY_OF_WORDS);
    WordDictonary := CreatListOfWords();
    ChoiceOfSecretWords(MatrixOfPlayersWords, WordDictonary, NumOfSecretWords);
    For I:= 0 To High(MatrixOfPlayersWords) Do
    Begin
        Writeln('Готово. Нажмите Enter, чтоб игрок ', I + 1, ' получил своё слово.');
        Readln;
        Writeln('Игрок ', I + 1);
        Writeln('Слово: ', MatrixOfPlayersWords[I][0]);
        J := 1;
        PartOfSpeech := Low(TPartOfSpeech);
        Repeat
            PartOfSpeech := Succ(PartOfSpeech);
            InputAnything(PartOfSpeech, MatrixOfPlayersWords, I, J);
            Inc(J, HINT_WORDS_NUM);
        Until (J > HIgh(MatrixOfPlayersWords[I]));
        ClearConsole;
    End;

End;


Function CreatingOrderForGuesing(NumberOfPlayers: Integer): TIntArr;
Var
     ArrayOfLineForGuessing: TIntArr;
     I: Integer;
Begin
     SetLength(ArrayOfLineForGuessing, NumberOfPlayers);
     For I := 0 To NumberOfPlayers - 1 Do
     Begin
         ArrayOfLineForGuessing[I] := (I + 1) Mod NumberOfPlayers;
     End;
     CreatingOrderForGuesing := ArrayOfLineForGuessing;
End;


Function CheckIsEnd(Const ArrPoints:TIntArr; Out ListWinner:TList<Integer>):Boolean;
Var
    Index, MaxPoints:Integer;
Begin
    MaxPoints := ArrPoints[0];
    ListWinner.Add(0);
    For Var I := 1 To High(ArrPoints) Do
    Begin
        If (ArrPoints[I] > MaxPoints) Then
        Begin
            MaxPoints := ArrPoints[I];
            ListWinner.Clear;
            ListWinner.Add(I);
        End
        Else
        If (ArrPoints[I] = MaxPoints) Then
        Begin
            ListWinner.Add(I);
        End;
    End;
    CheckIsEnd := (MaxPoints >= WIN_POINTS_NUM);
End;

Procedure OutputResult(Const ArrPoints:TIntArr);
Begin
    Writeln('Таблица баллов:');
    For Var I := 0 To High(ArrPOints) Do
        Writeln('Игрок ', (I + 1), #9, ArrPoints[I], ' баллов');
End;



Function InputMethod(): Integer;
Var
    IsCorrect: Boolean;
    UserAnswer: Integer;
Begin
    IsCorrect := False;
    Repeat
        IsCorrect := True;
        Try
            Readln(UserAnswer);
        Except
            Writeln('Введите ', CHOOSE_PRINT_TASK, '/', CHOOSE_START_GAME, '.');
            IsCorrect := False;
        End;
        If IsCorrect And (UserAnswer <> CHOOSE_PRINT_TASK) And (UserAnswer <> CHOOSE_START_GAME) Then
        Begin
            IsCorrect := False;
            Writeln('Введите ', CHOOSE_PRINT_TASK, '/', CHOOSE_START_GAME, '.');
        End;
    Until IsCorrect;
    InputMethod := UserAnswer;
End;


Procedure PrintTask();
Begin
    Writeln('Введите ', CHOOSE_START_GAME,' если хотите начать игру, ', CHOOSE_PRINT_TASK, ' если хотите вывести правила.');
    If InputMethod() = CHOOSE_PRINT_TASK Then
    Begin
        Writeln(#10#13, 'Правила: ');
        Writeln('В игре участвуют от ', PLAYERS_MIN_NUM, ' до ',
      PLAYERS_MAX_NUM, ' игроков.', #10#13,
      'Игра делится на несколько раундов. Каждый раунд проходит в два этапа. Игроки садятся за компьютер поочередно.',
      #10#13, 'Каждому игроку выдаётся слово, игрок отвечает на 3 вопроса о нём', #10#13,
      'После того, как все игроки ответили на свои вопросы, начинается следующий этап:', #10#13,
      '     Каждый игрок пытается отгадать слово одного из соперников.', #10#13,
      '     Сначала на экран выводятся только прилагательные, и игрок вводит свой вариант слова.', #10#13,
      '     Если он ошибся, то на экране отображаются еще и 3 глагола, и у игрока снова появляется возможност угадать слово.', #10#13,
      '     Если слово не угадано, то на экран выводятся еще и существительные.',
      #10#13, 'Игра длится до тех пор, пока хотя бы один из игроков не наберет 15 очков, которые даются за правильно угаданное слово.', #10#13);
    End;
End;


Procedure OutputWinners(ListWinner:TList<Integer>);
Var
    I: Integer;

Begin
    Try
    For I In ListWinner Do
    Begin
        Writeln('Победил игрок №', I + 1);
    End;
    Finally
        ListWinner.Free;
    End;

End;


Var
    NumberOfPLayers: Integer;
    Words: TStrMatrix;
    Arr,ArrPoints:TIntArr;
    ListWinner:TList<Integer>;
    IsEnd:Boolean;
Begin
    PrintTask;
    NumberOfPlayers := EnterNumberOfPlayers();
    SetLength(Words, NumberOfPLayers,  MAX_WORDS_NUM_IN_ROW);
    SetLength(ArrPoints, NumberOfPlayers);
    ListWinner := TList<Integer>.Create;
    Repeat
        ListWinner.Clear;
        InputData(Words, NumberOfPLayers);
        Arr := CreatingOrderForGuesing(NumberOfPLayers);
        OutputAssociation(Words,Arr,ArrPoints);
        IsEnd := CheckIsEnd(Arrpoints, ListWinner);
        OutputResult(ArrPoints);
    Until (IsEnd);
    OutputWinners(ListWinner);

    Readln;
End.
