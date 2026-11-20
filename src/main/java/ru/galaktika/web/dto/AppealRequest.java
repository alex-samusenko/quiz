package ru.galaktika.web.dto;

import java.util.List;

public record AppealRequest(
        List<Integer> questionIndexes,
        String exampleDescription,
        String interpretation,
        String legalReference,
        String attachmentName,
        String attachmentType,
        String attachmentBase64) {
}
