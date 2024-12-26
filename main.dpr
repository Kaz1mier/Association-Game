Program main;

{$APPTYPE CONSOLE}

Uses
    System.SysUtils,
    Classes,
    Windows,
    System.Generics.Collections;

Const
    NOUN_ENDIGNS: Set Of AnsiChar = ['а', 'я', 'о', 'е'];
    CONSONANTS: Set Of AnsiChar = ['б', 'в', 'г', 'д', 'ж', 'з', 'к', 'л', 'м', 'й', 'н', 'п', 'р', 'с', 'т', 'ф', 'х', 'ц', 'ч', 'ш', 'щ'];
    VOWELS: Set Of AnsiChar = ['а', 'е', 'ё', 'и', 'о', 'у', 'ы', 'э', 'ю', 'я'];
    LETTERS: Set Of AnsiChar = ['а' .. 'я', 'ё'];
    ADJECTIVE_ENDINGS: Array [0 .. 2] Of AnsiString = ('ый', 'ий', 'ой');
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

Function CheckIsWord(Const Word: AnsiString): Boolean;
Var
    I: Integer;
    IsValid, HasVowel, HasConsonant: Boolean;
Begin
    HasConsonant := False;
    HasVowel := False;
    IsValid := True;
    I := 1;

    If High(Word) > 1 Then
        While (I <= High(Word)) And IsValid Do
        Begin
            If Not(Word[I] In LETTERS) Then
            Begin
                IsValid := False;
                Writeln('Такого слова не существует или оно не из русского языка!');
            End
            Else
                If Not(I = High(Word)) And (Word[I] In VOWELS) Then
                    HasVowel := True
                Else
                    If (Word[I] In CONSONANTS) Then
                        HasConsonant := True;
            Inc(I);
        End
    Else
        Begin
            IsValid := False;
            Writeln('Вы не ввели слово или оно состоит из одной буквы!');
        End;

    If IsValid And (Not HasVowel Or Not  HasConsonant) Then
        Writeln('В слове одни гласные или согласные.');
    IsValid := IsValid And HasVowel And HasConsonant;
    CheckIsWord := IsValid;
End;

Function CheckIsVerb(Const Word: AnsiString): Boolean;
Var
    IsValid: Boolean;
    LastLet, PredLastLet: AnsiChar;
Begin
    IsValid := False;

    IsValid := ((Word[High(Word)] = 'ь') And (Word[High(Word) - 1] = 'т') And (Word[High(Word) - 2] In VOWELS) And (Word[High(Word) - 3] In CONSONANTS)) Or
        ((Word[High(Word) - 1] = 'с') And (Word[High(Word)] = 'я'));

    LastLet := Word[High(Word)];
    PredLastLet := Word[High(Word) - 1];
    IsValid := ((Word[High(Word)] = 'ь') And (Word[High(Word) - 1] = 'т')) Or ((PredLastLet = 'с') And (LastLet = 'я'));


    CheckIsVerb := IsValid;
End;

Function CheckIsAdjective(Const Word: AnsiString): Boolean;
Var
    I: Integer;
    WordEnding: AnsiString;
    IsValid: Boolean;
Begin
    IsValid := False;
    WordEnding := Word[High(Word) - 1] + Word[High(Word)];
    For I := 0 To High(ADJECTIVE_ENDINGS) Do
    If WordEnding = ADJECTIVE_ENDINGS[I] Then
        IsValid := True;

    If (Length(Word) < 3) Or  (not (Word[Length(Word) - 2] in CONSONANTS)) Then
            IsValid := False;
    CheckIsAdjective := IsValid;
End;

Function CheckIsNoun(Const Word: AnsiString): Boolean;
Var
    LastLet, PredLastLet: AnsiChar;
    IsValid: Boolean;
Begin
    IsValid := False;
    LastLet := Word[High(Word)];
    PredLastLet := Word[High(Word) - 1];
    IsValid := (Not CheckIsAdjective(Word) And Not CheckIsVerb(Word)) And
        (((LastLet In CONSONANTS) Or ((PredLastLet In CONSONANTS)) And ((LastLet = 'ь') Or (LastLet In NOUN_ENDIGNS))));

    CheckIsNoun := IsValid;
End;

Function CheckPartOfSpeech(Const Word: AnsiString; PartOfSpeech: TPartOfSpeech): Boolean;
Var
    IsValid: Boolean;
Begin
    Case PartOfSpeech Of
        TPS_ADJ:
            IsValid := CheckIsAdjective(Word);
        TPS_VERB:
            IsValid := CheckIsVerb(Word);
        TPS_NOUN:
            IsValid := CheckIsNoun(Word);
    End;

    CheckPartOfSpeech := IsValid;
End;

Procedure InputHintWords(PartOfSpeech:TPartOfSpeech; Words: TStrMatrix; I,J : Integer; SecreteWord: String);
Var
    Word: String;
    IsValid: Boolean;
Begin
    Writeln('Введите ', NUM_OF_HINT_WORDS, SPEECH_PARTS_ARR[Ord(PartOfSpeech)]);
    For Var K := 0 To NUM_OF_HINT_WORDS - 1 Do
    Begin
        Repeat
            Readln(Word);
            LowerCase(Word);
            IsValid := Not (SecreteWord = Word) And CheckIsWord(Word) And CheckPartOfSpeech(Word, PartOfSpeech);
            If Not IsValid then
                Writeln('Некорректное слово. Попробуйте сново.');
        Until IsValid;
        Words[I][K+J] := Word;
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

Procedure CountPoints(Var ArrPoints: TIntArr; Const Order: TIntArr; Const I, J: Integer; Const IsAnswerCorrect: Boolean);
Begin
    If IsAnswerCorrect Then
    Begin
        ArrPoints[I] := ArrPoints[I] + NUM_OF_ATTEMPTS - J Div 3 + 1;
        Inc(ArrPoints[Order[I]]);
    End
    Else
        Dec(ArrPoints[Order[I]]);
End;

Function RunPlayerTurn(Var I, J: Integer; Const MatrixOfPlayersWords: TStrMatrix; PartOfSpeech: TPartOfSpeech;
    Const Order: TIntArr): Boolean;
Var
    IsCorrect: Boolean;
Begin
    IsCorrect := False;
    While (Not IsCorrect) And (J <= High(MatrixOfPlayersWords[I])) Do
    Begin
        PartOfSpeech := Succ(PartOfSpeech);
        Writeln(SPEECH_PARTS_ARR[Ord(PartOfSpeech) + NUM_OF_SPEECH_PARTS]);
        For Var K := 0 To NUM_OF_HINT_WORDS - 1 Do
            Writeln(MatrixOfPlayersWords[Order[I]][J + K]);
        Inc(J, NUM_OF_HINT_WORDS);
        IsCorrect := GuessingSecreteWord(MatrixOfPlayersWords[Order[I]][0]);
    End;

    RunPlayerTurn := IsCorrect;
End;

Procedure RunRound(Const MatrixOfPlayersWords: TStrMatrix; Const Order: TIntArr; Var ArrPoints: TIntArr);
Var
    J: Integer;
    PartOfSpeech: TPartOfSpeech;
    IsCorrect: Boolean;
Begin
    For Var I := 0 To High(Order) Do
    Begin
        Writeln('Игрок ', I + 1);
        J := 1;
        IsCorrect := False;
        PartOfSpeech := Low(TPartOfSpeech);
        IsCorrect := RunPlayerTurn(I, J, MatrixOfPlayersWords, PartOfSpeech, Order);
        CountPoints(ArrPoints, Order, I, J, IsCorrect);
        If I = High(Order) Then
            Writeln('Переход к результатам')
        Else
            Writeln('Переход к игроку ', I + 2);
        Readln;

        ClearConsole();
    End;
End;

Procedure InputDataForRound(MatrixOfPlayersWords: TStrMatrix; NumberOfPLayers: Integer);
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
            InputHintWords(PartOfSpeech, MatrixOfPlayersWords, I, J, MatrixOfPlayersWords[I][0]);
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

Procedure OutputResultTable(Const ArrPoints: TIntArr);
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

Function StartGame(Words: TStrMatrix; NumOfPlayers: Integer; ArrPoints: TIntArr): TList<Integer>;
Var
    I: Integer;
    ListWinner: TList<Integer>;
    IsEnd: Boolean;
    Order: TIntArr;
Begin
    ListWinner := TList<Integer>.Create;
    Repeat
        ListWinner.Clear;
        InputDataForRound(Words, NumOfPlayers);
        Order := CreatingOrderForGuesing(NumOfPlayers);
        RunRound(Words, Order, ArrPoints);
        IsEnd := CheckIsEnd(Arrpoints, ListWinner);
        OutputResultTable(ArrPoints);
    Until (IsEnd);
    StartGame := ListWinner;

End;

Procedure OutputWinners(ListWinner: TList<Integer>);
Var
    I: Integer;
Begin
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
    ArrPoints: TIntArr;

Begin
    PrintTask;
    NumOfPlayers := EnterNumberOfPlayers();
    SetLength(Words, NumOfPlayers, NUM_OF_MAX_WORDS_IN_ROW);
    SetLength(ArrPoints, NumOfPlayers);
    OutputWinners(StartGame(Words, NumOfPlayers, ArrPoints));
    Readln;
End.
