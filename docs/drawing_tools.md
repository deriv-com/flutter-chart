# Drawing Tools

The process initiates by opening the drawing tools dialog and selecting a preferred drawing tool. Subsequently, the user can add specific taps on the Deriv chart to start drawing with default configurations.

The GestureDetector on the Deriv chart, utilized by the `drawingCreator` captures user input. Within the `onTap` method, every captured input will be added to the list of edgePoints. Simultaneously, the `drawingParts` list is created to store the drawing parts. Both lists are then passed to the `onAddDrawing` callback, which adds the complete drawing to the drawing repository and saves it in shared preferences based on the active Symbol, so the drawing data can be retrieved based on the chart's symbol.

During the addition of drawing parts to the `drawingParts` list, each instance of the drawing is initialized. This initialization triggers the relevant `onPaint` method, allowing each drawing part to be painted to the chart. Since we maintain a list of `drawingParts`, each of which is an instance of a drawing, every drawing part has its own `onPaint` and `hitTest` methods inherited from CustomPaint. Consequently, any modifications in the drawing's position, such as dragging, result in the `repaint` and `hitTest` methods being invoked for each drawing part. For a more detailed explanation, please refer to the sections titled DrawingPainter, EdgePoints, and DraggableEdgePoints.

Any modifications or adjustments to the drawing can be made by the user through the drawing tools dialog, it will end up in triggering an update in the drawing configuration within drawing_tools_dialog widget.

To enable the drawings to be draggable, a distinct gesture is assigned to each drawing added to the chart. This gesture, embedded within the DrawingPainter, identifies any user taps on the drawing and designates the drawing as selected or deselected. The user can then drag the selected drawing across the chart.

To update the position of the dragged drawing, the drawing must be repainted on the chart. This operation is performed by the CustomPaint component within the DrawingPainter.

## Drawing Tool Chart

DrawingToolChart widget is embedded within MainChart, enabling users to sketch particular shapes on DerivChart. This feature comprises two main parts: DrawingToolWidget and DrawingPainter. The DrawingPainter is specifically tasked with painting and repainting the drawings and is invoked for every drawing added to the chart.
In other words, for each drawing a DrawingPainter widget is added on the DrawingToolChart stack, and DrawingToolWidget is for when any drawing tool is selected.

## DrawingToolWidget

It assigns the task of drawing creation to the respective drawing tool creator. Each creator employs the chart's gestures to detect user inputs and initially adds the drawing to the list by invoking the onAddDrawing callback. Every drawing tool creator extends from the DrawingCreator class.

## DrawingCreator

It is a base class for all drawing tool creators. It is responsible for adding the drawing to the list and invoking the onAddDrawing callback. It also provides the drawing tool creator with the chart's gestures to detect user inputs.

## DrawingPainter

A stateful widget which is responsible for painting and repainting the drawings based on theirs configs using `CustomPaint`. Since the CustomPaint is wrapped within GestureDetector, each drawing created possesses its dedicated gesture, designed specifically for enabling the drawings to be draggable.

In this widget we make drawings selectable by means of gesture and `hitTest` of `CustomPainter`. `hitTest` method checks if the user has clicked on a drawing or not, if yes it will return true. Inside `CustomPaint` we are calling `onPaint` and `hitTest` for each drawingPart.

![plot](drawing_tools.png)

## EdgePoints

EdgePoint is a term we coined to keep the data of points required to create a drawing. For instance, a line necessitates two points, while a channel requires three. Whenever a user taps on Deriv-chart to create a drawing, a new instance of this class is generated within each drawing creator. This instance contains data obtained from Deriv_chart's gesture detector. These EdgePoints are then passed as a list to the onAddDrawing callback for drawing creation.

## DraggableEdgePints

This class extends from EdgePoint. It incorporates functions to compute the edgePoints' positions after they are dragged (utilizing data obtained from the DrawingPainter gestureDetector). These instances will be created as the state of the drawing_painter widget. Subsequently, they will be passed to CustomPaint, where onPaint and hitTest methods utilize them for drawing selection and repainting the drawings on the chart.
