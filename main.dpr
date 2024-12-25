Program main;

{$APPTYPE CONSOLE}

Uses
    System.SysUtils,
    Classes,
    Windows,
    System.Generics.Collections;

Const
    CHOICE_START_GAME = 0;
    CHOICE_PRINT_TASK = 1;
    NUM_OF_SPEECH_PARTS = 3;
    NUM_OF_HINT_WORDS = 3;
    NUM_OF_ATTEMPTS = 3;
    NUM_OF_WIN_POINTS = 15;
    NUM_OF_MAX_WORDS_IN_ROW = 10;
    MIN_NUM_OF_PLAYERS = 2;
    MAX_NUM_OF_PLAYERS = 5;
    SPEECH_PARTS_ARR: Array [1 .. NUM_OF_SPEECH_PARTS * 2] Of String = (' прилагательных:', ' глагола:', ' существительных:',
        'Прилагательные:', 'Глаголы:', 'Существительные:');

    START_DICTIONARY_OF_WORDS: Array [0 .. 88] Of String = ('стол', 'стул', 'книга', 'ручка', 'компьютер', 'телефон', 'окно', 'мяч',
        'машина', 'дом', 'сад', 'цветок', 'забор', 'печь', 'чашка', 'тарелка', 'ложка', 'вилка', 'нож', 'письмо', 'танк', 'город', 'парк',
        'вода', 'море', 'река', 'океан', 'воздух', 'мост', 'остров', 'страна', 'горы', 'яблоко', 'банан', 'апельсин', 'груша', 'арбуз',
        'пустыня', 'трава', 'мороженое', 'кровать', 'торт', 'суп', 'телефон', 'лестница', 'сок', 'яйцо', 'сыр', 'дверь', 'хлеб', 'ноутбук',
        'мясо', 'рыба', 'овощи', 'фрукты', 'молоко', 'сахар', 'соль', 'перец', 'ананас', 'клубника', 'вертолёт', 'самолёт', 'футбол',
        'баскетбол', 'зима', 'лето', 'осень', 'весна', 'теннис', 'забег', 'клад', 'велосипед', 'коньки', 'замок', 'пианино', 'корова',
        'орк', 'дракон', 'музыка', 'бог', 'рыцарь', 'кино', 'магия', 'меч', 'сказка', 'королевство', 'корона', 'видеоигра');

Type
    TStrMatrix = Array Of Array Of String;
    TPartOfSpeech = (TPS_NONE, TPS_ADJ, TPS_VERB, TPS_NOUN);
    TIntArr = Array Of Integer;


Procedure ClearConsole;
Var
    ConsoleHandle: THandle;
    ConsoleSize: DWORD;
    Written: DWORD;
    Coord: TCoord;
    ConsoleInfo: TConsoleScreenBufferInfo;
Begin
    ConsoleHandle := GetStdHandle(STD_OUTPUT_HANDLE);
    If ConsoleHandle = INVALID_HANDLE_VALUE Then
        Exit;
    If Not GetConsoleScreenBufferInfo(ConsoleHandle, ConsoleInfo) Then
        Exit;
    ConsoleSize := ConsoleInfo.DwSize.X * ConsoleInfo.DwSize.Y;
    Coord.X := 0;
    Coord.Y := 0;
    FillConsoleOutputCharacter(ConsoleHandle, ' ', ConsoleSize, Coord, Written);
    FillConsoleOutputAttribute(ConsoleHandle, ConsoleInfo.WAttributes, ConsoleSize, Coord, Written);
    SetConsoleCursorPosition(ConsoleHandle, Coord);
End;


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


Procedure ChoiceOfSecretWords(Words: TStrMatrix; Var WordDictonary: TStringList; Var Secret_Words_Amounts: Integer);
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
        If IsCorrect And (NumberOfPlayers < MIN_NUM_OF_PLAYERS) Or (NumberOfPlayers > MAX_NUM_OF_PLAYERS) Then
        Begin
            IsCorrect := False;
            Writeln('Неподходящее количество игроков! Количество игроков должно быть от ', MIN_NUM_OF_PLAYERS, ' до ',
                MAX_NUM_OF_PLAYERS, '!');
        End;
    Until IsCorrect;
    EnterNumberOfPlayers := NumberOfPlayers;
End;


Procedure InputWords(Words: TStrMatrix; I, J: Integer);
Var
    Word: String;
Begin
    For Var K := 0 To NUM_OF_HINT_WORDS - 1 Do
    Begin
        Readln(Word);
        LowerCase(Word);
        Words[I][K + J] := Word;
    End;
End;


Function GuessingSecreteWord(Const SecretWord: String): Boolean;
Var
    IsCorrect: Boolean;
    PlayerWord: String;
Begin
    IsCorrect := False;
    Writeln('Введите слово');
    Readln(PlayerWord);
    LowerCase(PlayerWord);
    If (PlayerWord = SecretWord) Then
    Begin
        IsCorrect := True;
        Writeln('Вы угадали слово.');
    End
    Else
        WriteLn('Вы не угадали слово.');
    GuessingSecreteWord := IsCorrect;
End;


Procedure OutputAssociation(Const MatrixOfPlayersWords: TStrMatrix; Const ArrGue: TIntArr; Var ArrPoints: TIntArr);
Var
    J: Integer;
    PartOfSpeech: TPartOfSpeech;
    IsCorrect: Boolean;
Begin
    For Var I := 0 To High(ArrGue) Do
    Begin
        Writeln('Игрок ', I + 1);
        J := 1;
        IsCorrect := False;
        PartOfSpeech := Low(TPartOfSpeech);
        While (Not IsCorrect) And (J <= High(MatrixOfPlayersWords[I])) Do
        Begin
            PartOfSpeech := Succ(PartOfSpeech);
            Writeln(SPEECH_PARTS_ARR[Ord(PartOfSpeech) + NUM_OF_SPEECH_PARTS]);
            For Var K := 0 To NUM_OF_HINT_WORDS - 1 Do
                Writeln(MatrixOfPlayersWords[ArrGue[I]][J + K]);
            Inc(J, NUM_OF_HINT_WORDS);
            IsCorrect := GuessingSecreteWord(MatrixOfPlayersWords[ArrGue[I]][0]);
        End;
        If IsCorrect Then
        Begin
            ArrPoints[I] := ArrPoints[I] + NUM_OF_ATTEMPTS - J Div 3 + 1;
            Inc(ArrPoints[ArrGue[I]]);
        End
        Else
            Dec(ArrPoints[ArrGue[I]]);
        If I = High(ArrGue) Then
            Writeln('Переход к результатам')
        Else
            Writeln('Переход к игроку ', I + 2);
        Readln;

        ClearConsole();
    End;
End;


Procedure InputAnything(PartOfSpeech: TPartOfSpeech; Words: TStrMatrix; I, J: Integer);
Begin
    Writeln('Введите ', NUM_OF_HINT_WORDS, SPEECH_PARTS_ARR[Ord(PartOfSpeech)]);
    InputWords(Words, I, J);
    { Case PartOfSpeech Of
      TPS_ADJ:
      Begin
      End;
      TPS_VERB:
      Begin
      End;
      TPS_NOUN:
      Begin
      End;
      End; }

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
    For I := 0 To High(MatrixOfPlayersWords) Do
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
            Inc(J, NUM_OF_HINT_WORDS);
        Until (J > HIgh(MatrixOfPlayersWords[I]));
        ClearConsole;
    End;

End;


Function CreatingOrderForGuesing(PlayersNum: Integer): TIntArr;
Var
    IsValid: Boolean;
    Order: TIntArr;
    RandomIndex, Temp, I: Integer;
Begin
    SetLength(Order, PlayersNum);
    For I := 0 To PlayersNum - 1 Do
        Order[I] := I;
    Repeat
        Randomize;
        For I := High(Order) Downto 1 Do
        Begin
            RandomIndex := Random(I + 1);
            Temp := Order[I];
            Order[I] := Order[RandomIndex];
            Order[RandomIndex] := Temp;
        End;
        For I := 0 To High(Order) Do
            IsValid := Not(I = Order[I]);
    Until IsValid;
    CreatingOrderForGuesing := Order;
End;


Function CheckIsEnd(Const ArrPoints: TIntArr; Out ListWinner: TList<Integer>): Boolean;
Var
    Index, MaxPoints: Integer;
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
    CheckIsEnd := (MaxPoints >= NUM_OF_WIN_POINTS);
End;


Procedure OutputResult(Const ArrPoints: TIntArr);
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
    UserAnswer := 0;
    Repeat
        IsCorrect := True;
        Try
            Readln(UserAnswer);
        Except
            Writeln('Введите ', CHOICE_PRINT_TASK, '/', CHOICE_START_GAME, '.');
            IsCorrect := False;
        End;
        If IsCorrect And (UserAnswer <> CHOICE_PRINT_TASK) And (UserAnswer <> CHOICE_START_GAME) Then
        Begin
            IsCorrect := False;
            Writeln('Введите ', CHOICE_PRINT_TASK, '/', CHOICE_START_GAME, '.');
        End;
    Until IsCorrect;
    InputMethod := UserAnswer;
End;


Procedure PrintTask();
Begin
    Writeln('Введите ', CHOICE_START_GAME, ' если хотите начать игру, ', CHOICE_PRINT_TASK, ' если хотите вывести правила.');
    If InputMethod() = CHOICE_PRINT_TASK Then
    Begin
        Writeln(#10#13, 'Правила: ');
        Writeln('В игре участвуют от ', MIN_NUM_OF_PLAYERS, ' до ', MAX_NUM_OF_PLAYERS, ' игроков.', #10#13,
            'Игра делится на несколько раундов. Каждый раунд проходит в два этапа. Игроки садятся за компьютер поочередно.', #10#13,
            'Каждому игроку выдаётся слово, игрок отвечает на 3 вопроса о нём', #10#13,
            'После того, как все игроки ответили на свои вопросы, начинается следующий этап:', #10#13,
            '     1.Каждый игрок пытается отгадать слово одного из соперников.', #10#13,
            '     2.Сначала на экран выводятся только прилагательные, и игрок вводит свой вариант слова.', #10#13,
            '     3.Если он ошибся, то на экране отображаются еще и 3 глагола, и у игрока снова появляется возможност угадать слово.',
            #10#13, '     4.Если слово не угадано, то на экран выводятся еще и существительные.', #10#13,
            'Игра длится до тех пор, пока хотя бы один из игроков не наберет 15 очков, которые даются за правильно угаданное слово.',
            #10#13);
    End;
End;


Procedure OutputWinners(Words: TStrMatrix; NumOfPlayers: Integer; Order, ArrPoints: TIntArr);
Var
    I: Integer;
    ListWinner: TList<Integer>;
    IsEnd: Boolean;
Begin
    ListWinner := TList<Integer>.Create;
    Repeat
        ListWinner.Clear;
        InputData(Words, NumOfPlayers);
        Order := CreatingOrderForGuesing(NumOfPlayers);
        OutputAssociation(Words, Order, ArrPoints);
        IsEnd := CheckIsEnd(Arrpoints, ListWinner);
        OutputResult(ArrPoints);
    Until (IsEnd);
    Try
        For I In ListWinner Do
        Begin
            Writeln('Победил игрок номер ', I + 1);
        End;
    Finally
        ListWinner.Free;
    End;

End;

Var
    NumOfPlayers: Integer;
    Words: TStrMatrix;
    Order, ArrPoints: TIntArr;
    ListWinner: TList<Integer>;

Begin
    PrintTask;
    NumOfPlayers := EnterNumberOfPlayers();
    SetLength(Words, NumOfPlayers, NUM_OF_MAX_WORDS_IN_ROW);
    SetLength(ArrPoints, NumOfPlayers);
    OutputWinners(Words, NumOfPlayers, Order, ArrPoints);
    Readln;
End.
