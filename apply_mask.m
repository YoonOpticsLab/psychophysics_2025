function new = apply_mask ( im, mask)
  % Apply mask. Images go from 0-1. So to properly mask, need
  % to recenter around zero, modulate with mask, then back to 0-1.
  new = im - 0.5;
  new = new .* mask;
  new = new + 0.5;
end
