module UI.Backend.Graphics exposing
    ( Graphics(..), map
    , Color(..), intRGBA
    , Rect, Corners, singletonRect, singletonCorners
    , empty, looseText, spanText
    , singleton, row, column, stack, indexedRow, indexedColumn, indexedStack, implicitGroup, Direction(..)
    , Attributes(..), PureAttributes, Layout, Events, Overflow(..), Inheritable(..)
    , Length(..), withWidth, withFitContentsX, withHeight, withFitContentsY, withSpacing
    , withPadding, withPaddingXY, withPaddingEach
    , withScrollingX, withScrollingY, Scroll(..), scrollInsetAlwaysVisible
    , withBackground, Background(..), backgroundColor
    , withBorder, Border(..), border1uBlack, borderWithColor
    , borderWithWidth, borderWithWidthXY, borderWithWidthEach
    , borderWithRounding, borderWithRoundingEach
    , withOuterShadow, Shadow(..), shadow1uBlack, shadowWithColor, shadowWithLengthXY, shadowWithBlurRadius, shadowWithSpreadRadius
    , withTextAlign, TextAlignment(..)
    , withAlignSelf, withJustifyItems, Alignment(..)
    , withFontColor, withFontSize, withFontWeight
    , withFontFamilies, FontFallback(..)
    , withInheritFontFamilies, withInheritFontColor, withInheritFontSize, withInheritFontWeight
    , withOnClick
    )

{-| Backend for the [UI module](https://github.com/UbiqueLambda/elm-with-ui) and [its renderer](https://github.com/UbiqueLambda/elm-with-ui-html).

**NOTE**: Here you have a clone of all the functions exposed in the UI module, to make it sure you'll develop properly against the real thing.

@docs Graphics, map

@docs Color, intRGBA

@docs Rect, Corners, singletonRect, singletonCorners

@docs empty, looseText, spanText

@docs singleton, row, column, stack, indexedRow, indexedColumn, indexedStack, implicitGroup, Direction

@docs Attributes, PureAttributes, Layout, Events, Overflow, Inheritable

@docs Length, withWidth, withFitContentsX, withHeight, withFitContentsY, withSpacing

@docs withPadding, withPaddingXY, withPaddingEach

@docs withScrollingX, withScrollingY, Scroll, scrollInsetAlwaysVisible

@docs withBackground, Background, backgroundColor

@docs withBorder, Border, border1uBlack, borderWithColor

@docs borderWithWidth, borderWithWidthXY, borderWithWidthEach

@docs borderWithRounding, borderWithRoundingEach

@docs withOuterShadow, Shadow, shadow1uBlack, shadowWithColor, shadowWithLengthXY, shadowWithBlurRadius, shadowWithSpreadRadius

@docs withTextAlign, TextAlignment

@docs withAlignSelf, withJustifyItems, Alignment

@docs withFontColor, withFontSize, withFontWeight

@docs withFontFamilies, FontFallback

@docs withInheritFontFamilies, withInheritFontColor, withInheritFontSize, withInheritFontWeight

@docs withOnClick

-}


{-| Type for describing atoms or groups.
-}
type Graphics msg
    = Atomic String
    | IndexedGroup (Attributes msg) (List (Graphics msg))
    | KeyedGroup (Attributes msg) (List ( String, Graphics msg ))


{-| Type for holding color primitives.
-}
type Color
    = IntRGBA Int


{-| Helper type for grouping top, right, bottom, and left distances (in units).
-}
type alias Rect =
    { top : Int, right : Int, bottom : Int, left : Int }


{-| Helper type for grouping topLeft, topRight, bottomRight, and bottomLeft metrics (in units).
-}
type alias Corners =
    { topLeft : Int, topRight : Int, bottomRight : Int, bottomLeft : Int }


{-| You are supposed to not let this type escape to the final API.

The direction in which a group grows.

-}
type Direction
    = Horizontal
    | Vertical
    | Stacked


{-| You are supposed to not let this type escape to the final API.

Where all the group's attributes are stored. Opaque layer.

-}
type Attributes msg
    = Attributes (PureAttributes msg)


{-| You are supposed to not let this type escape to the final API.

Where all the group's attributes are stored. Transparent layer.

-}
type alias PureAttributes msg =
    { layout : Layout
    , events : Events msg
    }


{-| You are supposed to not let this type escape to the final API.

This is a record, though I'm constantly reconsidering this because of the overhead created while updating it in V8.

Every attribute we current support is listed here. In the source of this file you can find the default values.

-}
type alias Layout =
    { alignSelf : Alignment -- "start" is default
    , background : Maybe Background
    , border : Maybe Border
    , displayDirection : Maybe Direction
    , fontColor : Inheritable Color -- inherit is default, "black" is root's default
    , fontFamilies : Inheritable ( List String, FontFallback ) -- inherit is default, "serif" is root's default
    , fontSize : Inheritable Int -- inherit is default, "16px" is root's default
    , fontWeight : Inheritable Int -- inherit is default, "400" is root's default
    , height : Length -- "fit-content" is default
    , justify : Alignment -- "start" is default
    , outerShadow : Maybe Shadow
    , overflowX : Overflow -- "clip" is default
    , overflowY : Overflow -- "clip" is default
    , padding : Rect -- zero is default
    , spacing : Int -- zero is default
    , textAlign : TextAlignment -- Default is LTR, but you should handle the localization problem yourself.
    , width : Length -- "fit-content" is default
    }


{-| You are supposed to not let this type escape to the final API
-}
type alias Events msg =
    { onClick : Maybe msg
    }


{-| You are supposed to not let this type escape to the final API
-}
type Overflow
    = Clip
    | Scrolling Scroll


{-| You are supposed to not let this type escape to the final API
-}
type Inheritable a
    = Inherit
    | Own a


{-| "Units" here is defined by the renderer, please, stop mixing a bunch of metrics (px, in, em) in the same surface.
-}
type Length
    = FitContents
    | Units Int


{-| Type for the possible options of scrolling.
-}
type Scroll
    = Scroll
        { alwaysVisible : Bool -- Even when contents in smaller then container
        , inset : Bool -- Wish they didn't deprecate overlay in HTML
        }


{-| Type for the possible backgrounds types.
-}
type Background
    = Background
        { color : Color
        }


{-| Type for describing border displaying.
-}
type Border
    = Border
        { color : Color
        , width : Rect
        , rounding : Corners
        }


{-| Type for the describing shadow displaying.
-}
type Shadow
    = Shadow
        { color : Color
        , lengthX : Int
        , lengthY : Int
        , blurRadius : Int
        , spreadRadius : Int
        }


{-| Type for the possible options of text alignemtn.
-}
type TextAlignment
    = TextLeft
    | TextCenter
    | TextRight


{-| Type for the possible alignment positions.
-}
type Alignment
    = Start
    | Center
    | End


{-| Type for the possible font fallbacks.
-}
type FontFallback
    = SansSerif
    | Serif
    | Monospace


{-| Usually used for nesting components.

    dropdownView model =
        UI.map ForDropdownMsg (MyDropdown.view model.dropdown)

-}
map : (a -> msg) -> Graphics a -> Graphics msg
map mapper graphics =
    let
        mapAttributes (Attributes { layout, events }) =
            Attributes
                { layout = layout
                , events = { onClick = Maybe.map mapper events.onClick }
                }

        recursiveMap original =
            case original of
                Atomic atomic ->
                    Atomic atomic

                IndexedGroup attributes list ->
                    IndexedGroup
                        (mapAttributes attributes)
                        (List.map recursiveMap list)

                KeyedGroup attributes list ->
                    KeyedGroup
                        (mapAttributes attributes)
                        (List.map (Tuple.mapSecond recursiveMap) list)
    in
    recursiveMap graphics


{-| Elm's Int is 32 bits, don't fear it, use hexadecimal for colors.

    red =
        intRGBA 0xFF0000FF

-}
intRGBA : Int -> Color
intRGBA int =
    IntRGBA int


{-| Creates a [`Rect`](#Rect) with the same value on all its sides
-}
singletonRect : Int -> Rect
singletonRect n =
    Rect n n n n


{-| Creates a [`Corners`](#Corners) with the same value on all its edges
-}
singletonCorners : Int -> Corners
singletonCorners n =
    Corners n n n n


{-| Empty figure.
-}
empty : Graphics msg
empty =
    looseText ""


{-| Text without a container. Don't have any special behavior, it just renders.

In HTML, this will insert text in the document without surrouding it in a tag.

**NOTE**: When you use any with-function in a loose-text, it automatically wraps in a [`singleton`](#singleton).
The result is then identical to a [`spanText`](#spanText).

-}
looseText : String -> Graphics msg
looseText value =
    Atomic value


{-| Wraps text within a container. Behaves according to the parent grouping disposition.

In HTML, this will insert text in the document without surrouding it in a `<div>` tag.

-}
spanText : String -> Graphics msg
spanText =
    looseText >> singleton


{-| Wraps a single element in a container.

    nestedSquares =
        UI.empty
            |> UI.withWidth 25
            |> UI.withHeight 25
            |> UI.withBorder (UI.border1uBlack |> Just)
            |> UI.singleton
            |> UI.withBorder (UI.border1uBlack |> UI.borderWithColor red |> Just)
            |> UI.singleton
            |> UI.withBorder (UI.border1uBlack |> UI.borderWithColor orange |> Just)
            |> UI.singleton
            |> UI.withBorder (UI.border1uBlack |> UI.borderWithColor yellow |> Just)
            |> UI.singleton
            |> UI.withBorder (UI.border1uBlack |> UI.borderWithColor green |> Just)
            |> UI.singleton
            |> UI.withBorder (UI.border1uBlack |> UI.borderWithColor cyan |> Just)
            |> UI.singleton
            |> UI.withBorder (UI.border1uBlack |> UI.borderWithColor blue |> Just)

-}
singleton : Graphics msg -> Graphics msg
singleton v =
    case v of
        Atomic "" ->
            IndexedGroup emptyAttributes []

        _ ->
            IndexedGroup emptyAttributes [ v ]


{-| Group itens disposing them horizontally.

    pageView model =
        [ ( "contents", contentsView model )
        , ( "tools", toolingView model )
        ]
            |> maybePrependSidebar model
            |> UI.row

-}
row : List ( String, Graphics msg ) -> Graphics msg
row =
    KeyedGroup emptyAttributes
        >> withDisplayDirection Horizontal


{-| Group itens disposing them vertically.

    shopList model =
        [ ( "pineapple", pineappleBox )
        , ( "rice", riceBox )
        , ( "onions", onionsBox )
        ]
            |> maybePrependBeans model
            |> UI.column

-}
column : List ( String, Graphics msg ) -> Graphics msg
column =
    row >> withDisplayDirection Vertical


{-| Group itens disposing them one above the other. Head goes on bottom, tails goes on top.

    pageView model =
        [ ( "contents", pageContents ) ]
            |> maybeAppendHalfOpaqueBlackOverlay model
            |> maybeAppendDialogBox
            |> UI.stack

-}
stack : List ( String, Graphics msg ) -> Graphics msg
stack =
    KeyedGroup emptyAttributes
        >> withDisplayDirection Stacked


{-| You're supposed to tell the user to avoid this

This is like [`row`](#row), but the virtual-dom struggles to know what to recreate and what to update.
It should be fine when you group elements that don't disappear, don't decrease in number, don't increment, and don't swap their order.

    tabsMenu =
        UI.indexedRow
            [ codeTab
            , issuesTab
            , prTab
            , wikiTab
            , settingsTab
            ]

-}
indexedRow : List (Graphics msg) -> Graphics msg
indexedRow =
    IndexedGroup emptyAttributes
        >> withDisplayDirection Horizontal


{-| You're supposed to tell the user to avoid this

This is like [`column`](#column), but the virtual-dom struggles to know what to recreate and what to update.
It should be fine when you group elements that don't disappear, don't decrease in number, don't increment, and don't swap their order.

    pageView =
        UI.indexedColumn
            [ header
            , text
            , footer
            ]

-}
indexedColumn : List (Graphics msg) -> Graphics msg
indexedColumn =
    indexedRow >> withDisplayDirection Vertical


{-| You're supposed to tell the user to avoid this

This is like [`stack`](#stack), but the virtual-dom struggles to know what to recreate and what to update.
It should be fine when you group elements that don't disappear, don't decrease in number, don't increment, and don't swap their order.

    tabsMenu =
        UI.indexedStack
            [ pageContents
            , halfOpaqueBlackOverlay
            , dialogBox
            ]

-}
indexedStack : List (Graphics msg) -> Graphics msg
indexedStack =
    IndexedGroup emptyAttributes
        >> withDisplayDirection Stacked


{-| You are supposed to not let this type escape to the final API
-}
implicitGroup : Graphics msg -> Graphics msg
implicitGroup v =
    case v of
        Atomic "" ->
            IndexedGroup emptyAttributes []

        Atomic _ ->
            IndexedGroup emptyAttributes [ v ]

        _ ->
            v


{-| Forces the group's width to a quantity in units.

By default, if the children's length is bigger, the content is cliped.
See [`withScrollingX`](#withScrollingX) to avoid it.

    someSquare =
        UI.empty
            |> UI.withWidth 64
            |> UI.withHeight 64
            |> UI.withBackground (UI.backgroundColor blue |> Just)

-}
withWidth : Int -> Graphics msg -> Graphics msg
withWidth width =
    withLayoutAttribute (\layout -> { layout | width = Units width })


{-| Instead of forcing the width, have enougth to show all the children contents.

For forcing a fixed one, see [`withWidth`](#withWidth).

-}
withFitContentsX : Graphics msg -> Graphics msg
withFitContentsX =
    withLayoutAttribute (\layout -> { layout | width = FitContents })


{-| Forces the group's height to a quantity in units.

By default, if the children's length is bigger, the content is cliped.
See [`withScrollingY`](#withScrollingY) to avoid it.

    someSquare =
        UI.empty
            |> UI.withWidth 64
            |> UI.withHeight 64
            |> UI.withBackground (UI.backgroundColor blue |> Just)

-}
withHeight : Int -> Graphics msg -> Graphics msg
withHeight height =
    withLayoutAttribute (\layout -> { layout | height = Units height })


{-| Instead of forcing the height, have enougth to show all the children contents.

For forcing a fixed one, see [`withHeight`](#withHeight).

-}
withFitContentsY : Graphics msg -> Graphics msg
withFitContentsY =
    withLayoutAttribute (\layout -> { layout | height = FitContents })


{-| Empty space between the items of a group, in units.

    spacedRow =
        UI.row [ item1, item2, item3 ]
            |> UI.withSpacing 8

-}
withSpacing : Int -> Graphics msg -> Graphics msg
withSpacing spacing =
    withLayoutAttribute (\layout -> { layout | spacing = spacing })


{-| Applies empty space, in units, repeatedly on top, bottom, left and right, surrounding the group.

    square =
        UI.spanText "Hello World!"
            |> UI.withPadding 12
            |> UI.withBorder (UI.border1uBlack |> Just)

-}
withPadding : Int -> Graphics msg -> Graphics msg
withPadding padding =
    withLayoutAttribute (\layout -> { layout | padding = singletonRect padding })


{-| Applies empty space, in units, to X (left and right) and Y (top and bottom).

    square =
        UI.spanText "Hello World!"
            |> UI.withPaddingXY 12 16
            |> UI.withBorder (UI.border1uBlack |> Just)

-}
withPaddingXY : Int -> Int -> Graphics msg -> Graphics msg
withPaddingXY x y =
    withLayoutAttribute (\layout -> { layout | padding = { top = y, right = x, bottom = y, left = x } })


{-| Applies empty space, in units, surrounding the group.

    square =
        UI.spanText "Hello World!"
            |> UI.withPaddingEach { top = 1, right = 3, bottom = 4, left = 2 }
            |> UI.withBorder (UI.border1uBlack |> Just)

-}
withPaddingEach : Rect -> Graphics msg -> Graphics msg
withPaddingEach rect =
    withLayoutAttribute (\layout -> { layout | padding = rect })


{-| When the contents of a group does not fit into the group's width, you might want to show a horizontal scroll bar.

See [`scrollInsetAlwaysVisible`](#scrollInsetAlwaysVisible) for the only value available right now.
`Nothing` means the content will be horizontally clipped (default behavior).

    horizontalScrollbars items =
        UI.row items
            |> UI.withPadding 16
            |> UI.withScrollingX (Just UI.scrollInsetAlwaysVisible)

-}
withScrollingX : Maybe Scroll -> Graphics msg -> Graphics msg
withScrollingX maybeScroll =
    withLayoutAttribute
        (\layout ->
            { layout
                | overflowX =
                    maybeScroll
                        |> Maybe.map Scrolling
                        |> Maybe.withDefault Clip
            }
        )


{-| When the contents of a group does not fit into the group's height, you might want to show a vertical scroll bar.

See [`scrollInsetAlwaysVisible`](#scrollInsetAlwaysVisible) for the only value available right now.
`Nothing` means the content will be vertically clipped (default behavior).

    verticalScrollbars items =
        UI.column items
            |> UI.withPadding 16
            |> UI.withScrollingY (Just UI.scrollInsetAlwaysVisible)

-}
withScrollingY : Maybe Scroll -> Graphics msg -> Graphics msg
withScrollingY maybeScroll =
    withLayoutAttribute
        (\layout ->
            { layout
                | overflowY =
                    maybeScroll
                        |> Maybe.map Scrolling
                        |> Maybe.withDefault Clip
            }
        )


{-| The (default) HTML-like way of adding scrollbars to any group.

The scrollbar is inset, relative to the group's dimensions.
And is always visible indiferent to the length of the group's contents.

See [`withScrollingX`](#withScrollingX) and [`withScrollingY`](#withScrollingY) for usage.

-}
scrollInsetAlwaysVisible : Scroll
scrollInsetAlwaysVisible =
    Scroll
        { alwaysVisible = True
        , inset = True
        }


{-| Applies a background to an element.

    square =
        UI.empty
            |> UI.withWidth 32
            |> UI.withHeight 32
            |> UI.withBackground (UI.backgroundColor black |> Just)

-}
withBackground : Maybe Background -> Graphics msg -> Graphics msg
withBackground maybeBackground =
    withLayoutAttribute (\layout -> { layout | background = maybeBackground })


{-| Creates a background and fills it with a specific color.

    green =
        UI.intRGBA 0x00FF00FF

    greenSquare =
        UI.empty
            |> UI.withWidth 32
            |> UI.withHeight 32
            |> UI.withBackground (UI.backgroundColor green |> Just)

-}
backgroundColor : Color -> Background
backgroundColor color =
    Background { color = color }


{-| Applies borders to an element.

    square =
        UI.empty
            |> UI.withWidth 32
            |> UI.withHeight 32
            |> UI.withBorder (UI.border1uBlack |> Just)

-}
withBorder : Maybe Border -> Graphics msg -> Graphics msg
withBorder maybeBorder =
    withLayoutAttribute (\layout -> { layout | border = maybeBorder })


{-| Creates a border with 1 unit on each side, solid and black.

    emptySquare =
        UI.empty
            |> UI.withWidth 31
            |> UI.withHeight 31
            |> UI.withBorder (UI.border1uBlack |> Just)

-}
border1uBlack : Border
border1uBlack =
    Border { color = black, width = singletonRect 1, rounding = singletonCorners 0 }


{-| Changes the color of all sides of the border.

    pink =
        UI.intRGBA 0xFFC0CBFF

    emptySquare =
        UI.empty
            |> UI.withWidth 31
            |> UI.withHeight 31
            |> UI.withBorder (UI.border1uBlack |> UI.borderWithColor pink |> Just)

-}
borderWithColor : Color -> Border -> Border
borderWithColor color (Border border) =
    Border { border | color = color }


{-| Specify one width value to all sides of the border in units.

    emptySquare32x32 =
        UI.empty
            |> UI.withWidth 24
            |> UI.withHeight 24
            |> UI.withBorder (UI.border1uBlack |> UI.borderWithWidth 4 |> Just)

-}
borderWithWidth : Int -> Border -> Border
borderWithWidth width (Border border) =
    Border { border | width = singletonRect width }


{-| Specify the width of X (pair left-right) and Y (pair top-bottom) borders in units.

    emptySquare32x32 =
        UI.empty
            |> UI.withWidth 28
            |> UI.withHeight 24
            |> UI.withBorder
                (UI.border1uBlack
                    |> UI.borderWithWidthXY 2 4
                    |> Just
                )

-}
borderWithWidthXY : Int -> Int -> Border -> Border
borderWithWidthXY x y (Border border) =
    Border { border | width = { top = y, right = x, bottom = y, left = x } }


{-| Specify the width of each side's border.

    emptySquare32x32 =
        UI.empty
            |> UI.withWidth 24
            |> UI.withHeight 24
            |> UI.withBorder
                (UI.border1uBlack
                    |> UI.borderWithWidthEach
                        { top = 6
                        , right = 5
                        , bottom = 2
                        , left = 3
                        }
                    |> Just
                )

-}
borderWithWidthEach : Rect -> Border -> Border
borderWithWidthEach widthRect (Border border) =
    Border { border | width = widthRect }


{-| Rounds all the corners of said group, including border, content and background (in units).

    emptyCircle =
        UI.empty
            |> UI.withWidth 31
            |> UI.withHeight 31
            |> UI.withBorder (UI.border1uBlack |> UI.borderWithRounding 16 |> Just)

-}
borderWithRounding : Int -> Border -> Border
borderWithRounding rounding (Border border) =
    Border { border | rounding = singletonCorners rounding }


{-| Rounds each of the corners of said group, including border, content and background (in units).

    emptyRoudedSquare =
        UI.empty
            |> UI.withWidth 31
            |> UI.withHeight 31
            |> UI.withBorder
                (UI.border1uBlack
                    |> UI.borderWithRoundingEach
                        { topLeft = 8
                        , topRight = 8
                        , bottomRight = 4
                        , bottomLeft = 4
                        }
                    |> Just
                )

-}
borderWithRoundingEach : Corners -> Border -> Border
borderWithRoundingEach roundingCorners (Border border) =
    Border { border | rounding = roundingCorners }


{-| Applies outer-shadow to an element.

    square =
        UI.empty
            |> UI.withWidth 32
            |> UI.withHeight 32
            |> UI.withBorder (UI.border1uBlack |> Just)
            |> UI.withOuterShadow
                (shadow1uBlack |> shadowWithColor green |> Just)

-}
withOuterShadow : Maybe Shadow -> Graphics msg -> Graphics msg
withOuterShadow maybeShadow =
    withLayoutAttribute (\layout -> { layout | outerShadow = maybeShadow })


{-| The default shadow, black, 1 unit of length in X (slightly to the right) and Y (slightly to bottom),
1 unit of blur-radius and 1 unit of spread-radius.
-}
shadow1uBlack : Shadow
shadow1uBlack =
    Shadow
        { color = black
        , lengthX = 1
        , lengthY = 1
        , blurRadius = 1
        , spreadRadius = 1
        }


{-| Change some shadow's color.

    someShadow =
        UI.shadow1uBlack
            |> UI.shadowWithColor cyan

-}
shadowWithColor : Color -> Shadow -> Shadow
shadowWithColor color (Shadow shadow) =
    Shadow { shadow | color = color }


{-| Changes the length in units of some shadow.

  - Negatives X values means it grows to the left, positive X values means it grows to the right.
  - Negatives Y values means it grows to the top, positive Y values means it grows to the bottom.

```
someShadow =
    UI.shadow1uBlack
        |> UI.shadowWithLengthXY 12 12
```

-}
shadowWithLengthXY : Int -> Int -> Shadow -> Shadow
shadowWithLengthXY x y (Shadow shadow) =
    Shadow { shadow | lengthX = x, lengthY = y }


{-| Change some shadow's blur-radius in units.

    someShadow =
        UI.shadow1uBlack
            |> UI.shadowWithBlurRadius 12

-}
shadowWithBlurRadius : Int -> Shadow -> Shadow
shadowWithBlurRadius radius (Shadow shadow) =
    Shadow { shadow | blurRadius = radius }


{-| Change some shadow's spread-radius in units.

    someShadow =
        UI.shadow1uBlack
            |> UI.shadowWithBlurRadius 12

-}
shadowWithSpreadRadius : Int -> Shadow -> Shadow
shadowWithSpreadRadius radius (Shadow shadow) =
    Shadow { shadow | spreadRadius = radius }


{-| Where to align text inside a group.

    spacedRow =
        UI.spanText "Foo Bar"
            |> UI.withWidth 640
            |> UI.withTextAlign UI.textCenter

-}
withTextAlign : TextAlignment -> Graphics msg -> Graphics msg
withTextAlign alignment =
    withLayoutAttribute (\layout -> { layout | textAlign = alignment })


{-| Aligns an item relative to the cross-axis of its group.

    alignColumnContentsExample =
        UI.column
            [ pinkSquare
                |> UI.withAlignSelf UI.start
                |> Tuple.pair "aligned-on-left"
            , greenSquare
                |> UI.withAlignSelf UI.center
                |> Tuple.pair "aligned-on-center"
            , blueSquare
                |> UI.withAlignSelf UI.end
                |> Tuple.pair "aligned-on-right"
            ]

    alignRowContentsExample =
        UI.row
            [ pinkSquare
                |> UI.withAlignSelf UI.start
                |> Tuple.pair "aligned-on-top"
            , greenSquare
                |> UI.withAlignSelf UI.center
                |> Tuple.pair "aligned-on-center"
            , blueSquare
                |> UI.withAlignSelf UI.end
                |> Tuple.pair "aligned-on-bottom"
            ]

-}
withAlignSelf : Alignment -> Graphics msg -> Graphics msg
withAlignSelf alignment =
    withLayoutAttribute (\layout -> { layout | alignSelf = alignment })


{-| How to align the items of a group.
In a row and in a stack this affects how they're show horizontally.
In a column this affects how they're show vertically.

    alignRowContentsOnRightExample =
        UI.row
            [ pink32uSquare
            , green32uSquare
            , blue32uSquare
            ]
            |> UI.withWidth 640
            |> UI.withJustifyItems UI.end

-}
withJustifyItems : Alignment -> Graphics msg -> Graphics msg
withJustifyItems alignment =
    withLayoutAttribute (\layout -> { layout | justify = alignment })


{-| Changes the text's color.

Default text's color is inherited, where's in the root element it's black.

    coolTitle =
        UI.spanText "HELLO"
            |> UI.withFontColor pink

-}
withFontColor : Color -> Graphics msg -> Graphics msg
withFontColor color =
    withLayoutAttribute (\layout -> { layout | fontColor = Own color })


{-| Changes the text's size, in units.

Default text's color is inherited, where's in the root element it's 16 units.

    coolTitle =
        UI.spanText "HELLO"
            |> UI.withFontSize 24

-}
withFontSize : Int -> Graphics msg -> Graphics msg
withFontSize size =
    withLayoutAttribute (\layout -> { layout | fontSize = Own size })


{-| Changes the text's weight.

Default font's weight is inherited, where's in the root element it's 400.

    coolTitle =
        UI.spanText "BOLD"
            |> UI.withFontWeight 700

-}
withFontWeight : Int -> Graphics msg -> Graphics msg
withFontWeight weight =
    withLayoutAttribute (\layout -> { layout | fontWeight = Own weight })


{-| Changes the text's font family. Tries all the font in the list, stopping in the first one available.
The fallback is used when nothing in the list is available.

Default font family value is inherited, where's in the root element it's [`serif`](#FontFallback).

    coolTitle =
        UI.spanText "HELLO"
            |> UI.withFontFamilies
                [ "Borg Sans Mono"
                , "Fira Code"
                , "JuliaMono"
                , "Fantasque Sans Mono"
                ]
                UI.monospace

-}
withFontFamilies : List String -> FontFallback -> Graphics msg -> Graphics msg
withFontFamilies families fallback =
    withLayoutAttribute (\layout -> { layout | fontFamilies = Own ( families, fallback ) })


{-| Instead of forcing the font's family, inherit it from the parent group.

For forcing a fixed one, or to learn about default behavior, see [`withFontFamilies`](#withFontFamilies).

-}
withInheritFontFamilies : Graphics msg -> Graphics msg
withInheritFontFamilies =
    withLayoutAttribute (\layout -> { layout | fontFamilies = Inherit })


{-| Instead of forcing the font's color, inherit it from the parent group.

For forcing a fixed one, or to learn about default behavior, see [`withFontColor`](#withFontColor).

-}
withInheritFontColor : Graphics msg -> Graphics msg
withInheritFontColor =
    withLayoutAttribute (\layout -> { layout | fontColor = Inherit })


{-| Instead of forcing the font's size, inherit it from the parent group.

For forcing a fixed one, or to learn about default behavior, see [`withFontSize`](#withFontSize).

-}
withInheritFontSize : Graphics msg -> Graphics msg
withInheritFontSize =
    withLayoutAttribute (\layout -> { layout | fontSize = Inherit })


{-| Instead of forcing the font's weight, inherit it from the parent group.

For forcing a fixed one, or to learn about default behavior, see [`withFontWeight`](#withFontWeight).

-}
withInheritFontWeight : Graphics msg -> Graphics msg
withInheritFontWeight =
    withLayoutAttribute (\layout -> { layout | fontWeight = Inherit })


{-| Listen for click events and dispatches the choosen message.

**Implicit effect**: Changes the cursor to the platform's clickable-pointer, when available.

    button =
        UI.withOnClick Msg.IncrementCounter incrementButton

-}
withOnClick : msg -> Graphics msg -> Graphics msg
withOnClick onClickMsg =
    withEventAttribute (\events -> { events | onClick = Just onClickMsg })


black : Color
black =
    intRGBA 0xFF


emptyAttributes : Attributes msg
emptyAttributes =
    Attributes
        { layout =
            { alignSelf = Start
            , background = Nothing
            , border = Nothing
            , displayDirection = Nothing
            , fontColor = Inherit
            , fontFamilies = Inherit
            , fontSize = Inherit
            , fontWeight = Inherit
            , height = FitContents
            , justify = Start
            , outerShadow = Nothing
            , overflowX = Clip
            , overflowY = Clip
            , padding = singletonRect 0
            , spacing = 0
            , textAlign = TextLeft
            , width = FitContents
            }
        , events =
            { onClick = Nothing }
        }


withAttribute :
    (PureAttributes msg -> PureAttributes msg)
    -> Graphics msg
    -> Graphics msg
withAttribute pureMapper graphics =
    let
        mapper (Attributes attr) =
            Attributes <| pureMapper attr
    in
    case graphics of
        Atomic "" ->
            IndexedGroup (mapper emptyAttributes) []

        Atomic atom ->
            IndexedGroup (mapper emptyAttributes) [ Atomic atom ]

        IndexedGroup attributes group ->
            IndexedGroup (mapper attributes) group

        KeyedGroup attributes group ->
            KeyedGroup (mapper attributes) group


withDisplayDirection : Direction -> Graphics msg -> Graphics msg
withDisplayDirection direction =
    withLayoutAttribute (\layout -> { layout | displayDirection = Just direction })


withEventAttribute : (Events msg -> Events msg) -> Graphics msg -> Graphics msg
withEventAttribute mapper =
    withAttribute (\attr -> { attr | events = mapper attr.events })


withLayoutAttribute : (Layout -> Layout) -> Graphics msg -> Graphics msg
withLayoutAttribute mapper =
    withAttribute (\attr -> { attr | layout = mapper attr.layout })
