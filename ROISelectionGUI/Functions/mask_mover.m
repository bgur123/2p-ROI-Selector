function masks = mask_mover(masks, in, handles)
done = 0;
while ~done
    directionButton = input('','s');
            
    gain = 1;
    switch directionButton
        case 'w'
            for indMask = 1:length(masks)
                masks{indMask} = circshift(masks{indMask},-gain,1);

            end
            show_mask(masks, in, handles)

        case 's'
            for indMask = 1:length(masks)
                masks{indMask} = circshift(masks{indMask},gain,1);

            end
            show_mask(masks, in, handles)
        case 'd'
            for indMask = 1:length(masks)
                masks{indMask} = circshift(masks{indMask},gain,2);

            end
            show_mask(masks, in, handles)
        case 'a'
            for indMask = 1:length(masks)
                masks{indMask} = circshift(masks{indMask},-gain,2);

            end
            show_mask(masks, in, handles)
        case 'r'
            done = 1;
    end
end

