-- Track client FPS to dynamically add performance compensations when required

bKeypads.IsWindows = system.IsWindows()

bKeypads.Performance = {}
bKeypads.Performance.Optimize = false

function bKeypads.Performance:Optimizing()
	return
		bKeypads.Settings:Get("optimizations") ~= "none" and (
			bKeypads.Performance.Optimize or
			bKeypads.Settings:Get("optimizations") == "potato"
		)
end

function bKeypads.Performance:Alpha3D2D(dist)
	return 1 - math.Clamp((dist - 20000) / (bKeypads.Settings:Get("optimizations_3d2d_distance") ^ 2), 0, 1)
end

bKeypads.Performance.FPS = math.huge

bKeypads.Performance.FPSAverage = math.huge
bKeypads.Performance.FPSAverageClock = 0

bKeypads.Performance.FrameCount = 0
bKeypads.Performance.FrameNumber = FrameNumber()

timer.Create("bKeypads.Performance.FPS", 1, 0, function()
	bKeypads.Performance.FPS = FrameNumber() - bKeypads.Performance.FrameNumber
	bKeypads.Performance.FrameNumber = FrameNumber()
	bKeypads.Performance.FrameCount = bKeypads.Performance.FrameCount + bKeypads.Performance.FPS

	bKeypads.Performance.FPSAverageClock = bKeypads.Performance.FPSAverageClock + 1
	bKeypads.Performance.FPSAverage = bKeypads.Performance.FrameCount / bKeypads.Performance.FPSAverageClock

	if bKeypads.Performance.FPSAverageClock == 5 then
		bKeypads.Performance.FPSAverageClock = 1
		bKeypads.Performance.FrameCount = bKeypads.Performance.FPS
	end

	if bKeypads.IsWindows and not system.HasFocus() then
		bKeypads.Performance.Optimize = true
	else
		bKeypads.Performance.FPSThreshold = bKeypads.Performance.FPSThreshold or bKeypads.Settings:Get("optimizations_fps_threshold")
		if not bKeypads.Performance.Optimize and bKeypads.Performance.FPSAverage < bKeypads.Performance.FPSThreshold then
			bKeypads.Performance.FPSThreshold = bKeypads.Performance.FPSThreshold + 5
			bKeypads.Performance.Optimize = true
		elseif bKeypads.Performance.Optimize and bKeypads.Performance.FPSAverage > bKeypads.Performance.FPSThreshold then
			bKeypads.Performance.FPSThreshold = bKeypads.Performance.FPSThreshold - 5
			bKeypads.Performance.Optimize = false
		end
	end
end)