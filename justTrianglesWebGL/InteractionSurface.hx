package justTrianglesWebGL;

import js.Browser;
import js.html.HTMLDocument;
import js.html.DivElement;
import js.html.Event;
import js.html.MouseEvent;
import justTriangles.Point;

typedef Limit = {
    var left: Float;
    var right: Float;
    var top: Float;
    var bottom: Float;
}

class InteractionSurface<T:Point> {
    var doc: HTMLDocument;
    public var bg: DivElement;
    public var width: Int;
    public var height: Int;
    public var color: String;
    var limits: Array<Limit>;
    public var transform: Float->Float->Point;
    public var vertices: Array<T>;
    public var draw: Void->Void;
    public var radius: Float = 15;
    var currVertex: Int;
    
    public function new<T:Point>( width_: Int, height_: Int, color_: String ){
        width   = width_;
        height  = height_;
        color   = color_;
        createBackground();
    }
    public function setup(  vertices_:  Array<T>
                        ,   transform_: Float->Float->Point
                        ,   draw_:      Void->Void
                        ){
       vertices     = vertices_;
       transform    = transform_;
       draw         = draw_; 
       initVerticesHits();
    }
    inline function initVerticesHits(){
        limits = new Array<Limit>();
        var l = vertices.length;
        var v: T;
        for( i in 0...l ){
            v = vertices[i];
            setVertexLimit( i, v.x, v.y );
        }
    }
    inline function createBackground(){
        doc = Browser.document;
        bg = doc.createDivElement();
        bg.style.backgroundColor = color;
        bg.style.width = Std.string( width ) + 'px';
        bg.style.height = Std.string( height ) + 'px';
        bg.style.position = "absolute";
        bg.style.left = '0px';
        bg.style.top = '0px';
        bg.style.zIndex = '-100';
        bg.style.cursor = "default";
        doc.body.appendChild( bg );
        bg.addEventListener( 'mousedown', makePointsDragable );
    }
    function makePointsDragable( e: MouseEvent ){
        var i: Int = hitVertex( e.clientX * 2, e.clientY * 2 );
        if( i != null ) {
            currVertex = i;
            bg.style.cursor = "move";
            bg.addEventListener( 'mousemove', repositionVertex );
            bg.addEventListener( 'mouseup', killMouseMove );
        }
    }
    function hitVertex( x: Float, y: Float ){
        var aLimit: Limit;
        var p = transform( x, y );
        for( i in 0...limits.length ){
            aLimit = limits[ i ];
            if( p.x > aLimit.left && p.x < aLimit.right ){
                if( p.y > aLimit.top && p.y < aLimit.bottom ){
                    return i;
                }
            }
        }
        return null;
    }
    function killMouseMove( e: MouseEvent ){
        bg.style.cursor = "default";
        bg.removeEventListener( 'mousemove', repositionVertex );
        bg.removeEventListener( 'mouseup', killMouseMove );
    }
    function repositionVertex( e: MouseEvent ){
        var x: Float = e.clientX ;
        var y: Float = e.clientY ;
        moveVertex( currVertex, x, y );
    }
    inline function moveVertex( i: Int, x: Float, y: Float ){
        setVertexLimit( i, x, y );
        var v = vertices[ i ];
        v.x = x * 2;
        v.y = y * 2;
        draw();
    }
    inline function setVertexLimit( i: Int, x: Float, y: Float ){
        var p0 = transform( x - radius, y - radius );
        var p1 = transform( x + radius, y + radius );
        limits[ i ] = cast { left: p0.x, top: p0.y, right: p1.x, bottom: p1.y };
    }
}
