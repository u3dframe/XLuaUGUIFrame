
local package = package
function reimport(name)
    package.loaded[name] = nil
    package.preload[name] = nil
    return require(name)    
end

LayerMask	= reimport "UnityEngine.LayerMask"
Mathf		= reimport "UnityEngine.Mathf"
Vector3		= reimport "UnityEngine.Vector3"
Quaternion	= reimport "UnityEngine.Quaternion"
Vector2		= reimport "UnityEngine.Vector2"
Color		= reimport "UnityEngine.Color"
Time		= reimport "UnityEngine.Time"