//
//  Shader.fsh
//  OpenGLMilkyWay
//
//  Created by Hanno Rein on 12/17/12.
//  Copyright (c) 2012 Hanno Rein. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
