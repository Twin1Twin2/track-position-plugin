
return function(cframe: CFrame)
	local currentCamera = workspace.CurrentCamera
	currentCamera.CameraType = Enum.CameraType.Custom

	local currentCameraCFrame = currentCamera.CFrame
	local newCameraCFrame = CFrame.lookAt(cframe.Position, cframe.Position + currentCameraCFrame.LookVector) * CFrame.new(0, 0, 15)

	currentCamera.CFrame = newCameraCFrame
	currentCamera.Focus = newCameraCFrame
end